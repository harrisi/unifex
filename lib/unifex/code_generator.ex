defmodule Unifex.CodeGenerator do
  @moduledoc """
  Behaviour for code generation.
  """

  alias Unifex.Specs

  @type code_t :: String.t()
  @type generated_code_t :: {header :: code_t, source :: code_t, generator :: module()}

  @callback identification_constant() :: String.t()
  @callback subdirectory() :: String.t()
  @callback generate_header(specs :: Specs.t()) :: code_t
  @callback generate_source(specs :: Specs.t()) :: code_t

  @doc """
  Generates boilerplate code using generator implementation from `Unifex.CodeGenerators`.
  """
  @spec generate_code(Specs.t()) :: [generated_code_t()]
  def generate_code(specs) do
    for generator <- get_generators(specs) do
      header = generator.generate_header(specs)
      source = generator.generate_source(specs)
      {header, source, generator}
    end
  end

  @spec get_generators(Specs.t()) :: [module()]
  defp get_generators(%Specs{name: name, interface: nil}) do
    {:ok, bundlex_project} = Bundlex.Project.get()
    config = bundlex_project.config

    generators =
      [:natives, :libs]
      |> Enum.find_value(&get_in(config, [&1, name, :interface]))
      |> Enum.map(&bundlex_interface/1)
      |> Enum.map(&interface_generator/1)

    case generators do
      [] -> raise "Interface for native #{name} is not specified.
        Please specify it in your *.spec.exs or bundlex.exs file."
      _ -> generators
    end
  end

  defp get_generators(%Specs{interface: interfaces}) do
    interfaces
    |> Bunch.listify()
    |> Enum.map(&interface_generator/1)
  end

  @spec bundlex_interface(Bundlex.Native.interface_t()) :: Specs.interface_t()
  defp bundlex_interface(:cnode), do: CNode
  defp bundlex_interface(:nif), do: NIF

  @spec interface_generator(Specs.interface_t()) :: module()
  def interface_generator(CNode), do: Unifex.CodeGenerators.CNode
  def interface_generator(NIF), do: Unifex.CodeGenerators.NIF
end
