module Example

interface NIF

callback :load

state_type "MyState"

@doc """
init docs
"""
spec init() :: {:ok :: label, was_handle_load_called :: int, state}

@doc """
test_atom docs
"""
spec test_atom(in_atom :: atom) :: {:ok :: label, out_atom :: atom}

@doc false
spec test_float(in_float :: float) :: {:ok :: label, out_float :: float}

spec test_int(in_int :: int) :: {:ok :: label, out_int :: int}

spec test_nil() :: (nil :: label)

spec test_nil_tuple(in_int :: int) :: {nil :: label, out_int :: int}

@doc """
test_string docs
"""
spec test_string(in_string :: string) :: {:ok :: label, out_string :: string}

spec test_list(in_list :: [int]) :: {:ok :: label, out_list :: [int]}

spec test_list_of_strings(in_strings :: [string]) :: {:ok :: label, out_strings :: [string]}

spec test_pid(in_pid :: pid) :: {:ok :: label, out_pid :: pid}

spec test_state(state) :: {:ok :: label, state}

spec test_example_message(pid :: pid) :: {:ok :: label} | {:error :: label, reason :: atom}

sends {:example_msg :: label, num :: int}

type my_struct :: %My.Struct{
  id: int,
  data: [int],
  name: string
}

type simple_struct :: %SimpleStruct{
  id: int,
  name: string
}

spec test_my_struct(in_struct :: my_struct) :: {:ok :: label, out_struct :: my_struct}

type nested_struct :: %Nested.Struct{
  inner_struct: my_struct,
  id: int
}

type nested_struct_list :: %Nested.StructList{
  struct_list: [my_struct],
  id: int
}

spec test_nested_struct_list(in_struct :: nested_struct_list) :: {:ok :: label, out_struct :: nested_struct_list}

spec test_nested_struct(in_struct :: nested_struct) :: {:ok :: label, out_struct :: nested_struct}

spec test_list_of_structs(struct_list :: [simple_struct]) :: {:ok :: label, out_struct_list :: [simple_struct]}

type my_enum :: :option_one | :option_two | :option_three | :option_four | :option_five

type my_explicit_enum :: enum_value(:a, 1) | :b | enum_value(:c, 4) | enum_value(:d, 8)

@doc """
test_my_enum docs
"""
spec test_my_enum(in_enum :: my_enum) :: {:ok :: label, out_enum :: my_enum}


spec test_my_explicit_enum(in_enum :: my_explicit_enum) :: {:ok :: label, out_enum :: my_explicit_enum}

# tests for bugged version of functions returning nil.
# these tests should be removed in unifex v2.0.0. For more information check:
# https://github.com/membraneframework/membrane_core/issues/758

spec test_nil_bugged() :: (nil :: label)

spec test_nil_tuple_bugged(in_int :: int) :: {nil :: label, out_int :: int}
