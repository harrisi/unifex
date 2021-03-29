defmodule Unifex.CodeGenerator.BaseTypes.StructTemplate do
  def compile_struct_module(struct_type_name, struct_module_name, struct_fields) do
    r =
      module_code(struct_type_name, struct_module_name, struct_fields)
      |> Code.compile_string()

    # generated_module_name_sufix = struct_type_name |> Atom.to_string() |> Macro.camelize() |> String.to_atom()
    # generated_module_name = "Elixir.Unifex.CodeGenerator.BaseTypes.#{generated_module_name_sufix}" |> String.to_atom()

    generated_module_name =
      Module.concat(
        Unifex.CodeGenerator.BaseTypes,
        struct_type_name |> Atom.to_string() |> Macro.camelize()
      )

    IO.inspect(generated_module_name)

    Code.ensure_loaded(generated_module_name)
    |> IO.inspect(label: "dupa 2")

    Module.concat(generated_module_name, "CNode")
    |> Code.ensure_loaded()
    |> IO.inspect(label: "dupa 1")

    Kernel.function_exported?(generated_module_name, :generate_destruction, 2)
    |> IO.inspect(label: "dupa ma byc true")

    r
  end

  defp module_code(struct_type_name, struct_module_name, struct_fields) do
    EEx.eval_string(module_code_eex_template(),
      assigns: [
        struct_type_name: struct_type_name,
        struct_module_name: struct_module_name,
        struct_fields: struct_fields
      ]
    )
  end

  defp module_code_eex_template() do
    ~S/
    defmodule Unifex.CodeGenerator.BaseTypes.<%= @struct_type_name |> Atom.to_string() |> Macro.camelize() %> do
      use Unifex.CodeGenerator.BaseType
      alias Unifex.CodeGenerator.BaseType

      @impl BaseType
      def generate_initialization(name, ctx) do
        struct_fields()
        |> Enum.map(fn {field_name, field_type} ->
          BaseType.generate_initialization(field_type, :"#{name}.#{field_name}", ctx.generator)
        end)
        |> Enum.map(&(&1 != ""))
        |> Enum.join("\n")
        |> IO.inspect(label: "generate_initialization from #{__MODULE__}")

      end

      @impl BaseType
      def generate_destruction(name, ctx) do


        struct_fields()
        |> Enum.map(fn {field_name, field_type} ->
          BaseType.generate_destruction(field_type, :"#{name}.#{field_name}", ctx.generator)
        end)
        |> Enum.map(&(&1 != ""))
        |> Enum.join("\n")


        |> IO.inspect(label: "generate_destruction from #{__MODULE__}")

      end

      defmodule NIF do
        use Unifex.CodeGenerator.BaseType
        alias Unifex.CodeGenerator.BaseType

        @impl BaseType
        def generate_arg_serialize(name, ctx) do


          struct_fields_number = length(struct_fields())
          fields_serialization =
            struct_fields()
            |> Enum.zip(0..(struct_fields_number - 1))
            |> Enum.map(fn {field, idx} ->
              ~g"""
              keys[#{idx}] = enf_make_atom(env, "#{name}");
              values[#{idx}] = #{BaseType.generate_arg_serialize(field.type, :"#{name}.#{field.name}", ctx.generator)};
              """
            end)
            |> Enum.join("\n")

          ~g"""
          ({
            ERL_NIF_TERM keys[#{struct_fields_number + 1}];
            ERL_NIF_TERM values[#{struct_fields_number + 1}];

            #{fields_serialization}
            keys[#{struct_fields_number}] = enif_make_atom(env, "__struct__");
            values[#{struct_fields_number}] = enif_make_atom(env, "<%= @struct_module_name |> Atom.to_string() %>");

            ERL_NIF_TERM result;
            enif_make_map_from_arrays(env, keys, values, #{struct_fields_number + 1}, &result);
            result;
          })
          """

          |> IO.inspect(label: "generate_arg_serialize from #{__MODULE__}")

        end

        @impl BaseType
        def generate_arg_parse(arg, var_name, ctx) do


          %{postproc_fun: postproc_fun, generator: generator} = ctx

          fields_parsing =
            struct_fields()
            |> Enum.map(fn {field_name, field_type} ->
              ~g"""
              key = enif_make_atom(env, "#{field_name}");
              int get_#{field_name}_result = enif_get_map_value(env, #{arg}, key, &value);
              if (get_#{field_name}_result) {
                get_#{field_name}_result =
                  #{BaseType.generate_arg_parse(field_type, :"#{var_name}.#{field_name}", ~g<value>, postproc_fun, generator)}
              }
              """
            end)
            |> Enum.join("\n")

          result =
            struct_fields()
            |> Enum.map(fn {field_name, _field_type} -> ~g<get_#{field_name}_result> end)
            |> Enum.join(" && ")

          ~g"""
          ({
            ERL_NIF_TERM key;
            ERL_NIF_TERM value;

            #{fields_parsing}
            #{result};
          })
          """

          |> IO.inspect(label: "generate_arg_parse from #{__MODULE__}")

        end

        defp struct_fields() do
          <%= inspect(@struct_fields, limit: :infinity, printable_limit: :infinity) %>
        end
      end

      defmodule CNode do
        use Unifex.CodeGenerator.BaseType
        alias Unifex.CodeGenerator.BaseType

        @impl BaseType
        def generate_arg_serialize(name, ctx) do

          fields_serialization =
            struct_fields()
            |> Enum.map(fn field ->
              ~g"""
              ei_x_encode_atom(out_buff, "#{name}");
              #{BaseType.generate_arg_serialize(field.type, :"#{name}.#{field.name}", ctx.generator)};
              """
            end)
            |> Enum.join("\n")

          ~g"""
          ({
            ei_x_encode_map_header(out_buff, #{length(struct_fields()) + 1});
            #{fields_serialization}
            ei_x_encode_atom(out_buff, "__struct__");
            ei_x_encode_atom(out_buff, "<%= @struct_module_name |> Atom.to_string() %>");
          })
          """

          |> IO.inspect(label: "generate_arg_serialize from #{__MODULE__}")

        end

        @impl BaseType
        def generate_arg_parse(arg, var_name, ctx) do

          %{postproc_fun: postproc_fun, generator: generator} = ctx

          fields_parsing =
            struct_fields()
            |> Enum.map(fn {field_name, field_type} ->
              ~g"""
              if (strcmp(key, "#{field_name}") == 0) {
                #{BaseType.generate_arg_parse(field_type, :"#{var_name}.#{field_type}", arg, postproc_fun, generator)}
              }
              """
            end)
            |> Enum.join(" else ")

          ~g"""
          ({
            int arity = 0;
            int decode_map_header_result = ei_decode_map_header(#{arg}->buff, #{arg}->index, &arity);

            if (decode_map_header_result) {
              for (size_t i = 0; i < arity; ++i) {
                char key[MAXATOMLEN + 1];
                int decode_key_result = ei_decode_atom(#{arg}->buff, #{arg}->index, key);
                if (decode_key_result) {
                  #{fields_parsing}
                }
              }
            }

            decode_map_header_result;
          })
          """

          |> IO.inspect(label: "generate_arg_parse from #{__MODULE__}")

        end

        defp struct_fields() do
          <%= inspect(@struct_fields, limit: :infinity, printable_limit: :infinity) %>
        end
      end

      defp struct_fields() do
        <%= inspect(@struct_fields, limit: :infinity, printable_limit: :infinity) %>
      end
    end
    /
  end
end
