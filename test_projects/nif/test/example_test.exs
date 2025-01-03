defmodule ExampleTest do
  use ExUnit.Case

  setup_all do
    assert {:ok, was_handle_load_called, state} = Example.init()
    assert was_handle_load_called == 1
    assert is_reference(state)
    [state: state]
  end

  test "nil" do
    assert nil == Example.test_nil()
  end

  test "nil tuple" do
    assert {nil, 1} == Example.test_nil_tuple(1)
  end

  test "atom" do
    assert {:ok, :unifex} = Example.test_atom(:unifex)
  end

  test "float" do
    assert {:ok, 0.0} = Example.test_float(0.0)
    assert {:ok, 0.1} = Example.test_float(0.1)
    assert {:ok, -0.1} = Example.test_float(-0.1)
    refute match?({:ok, 1}, Example.test_float(1.0))
  end

  test "int" do
    assert {:ok, 10} = Example.test_int(10)
  end

  test "string" do
    assert {:ok, "unifex"} = Example.test_string("unifex")
  end

  test "list" do
    assert {:ok, [1, 2, 3]} = Example.test_list([1, 2, 3])
  end

  test "list of strings" do
    l = ["unifex", "is", "really", "cool"]
    assert {:ok, ^l} = Example.test_list_of_strings(l)
  end

  test "pid" do
    pid = self()
    assert {:ok, ^pid} = Example.test_pid(pid)
  end

  test "state", context do
    state = context[:state]
    assert {:ok, ^state} = Example.test_state(state)
  end

  test "example message" do
    assert {:ok} = Example.test_example_message(self())
    assert_receive {:example_msg, 10}
  end

  test "struct" do
    my_struct = %My.Struct{id: 1, name: "Jan Kowlaski", data: [1, 2, 3, 4, 5, 6, 7, 8, 9]}
    assert {:ok, ^my_struct} = Example.test_my_struct(my_struct)

    nested_struct = %Nested.Struct{id: 2, inner_struct: my_struct}
    assert {:ok, ^nested_struct} = Example.test_nested_struct(nested_struct)

    invalid_struct = %Nested.Struct{id: 3, inner_struct: "Unifex"}

    assert_raise ErlangError, ~r/unifex_parse_arg.*in_struct.*nested_struct/i, fn ->
      Example.test_nested_struct(invalid_struct)
    end
  end

  test "enum" do
    assert {:ok, :option_one} = Example.test_my_enum(:option_one)
    assert {:ok, :option_two} = Example.test_my_enum(:option_two)
    assert {:ok, :option_three} = Example.test_my_enum(:option_three)

    assert_raise ErlangError, ~r/unifex_parse_arg.*in_enum.*my_enum/i, fn ->
      Example.test_my_enum(:option_not_mentioned)
    end
  end

  test "explicit enum" do
    assert {:ok, :a} = Example.test_my_explicit_enum(:a)
    assert {:ok, :b} = Example.test_my_explicit_enum(:b)
    assert {:ok, :c} = Example.test_my_explicit_enum(:c)
    assert {:ok, :d} = Example.test_my_explicit_enum(:d)

    assert_raise ErlangError, ~r/unifex_parse_arg.*in_enum.*my_explicit_enum/i, fn ->
      Example.test_my_explicit_enum(:option_not_mentioned)
    end
  end

  test "nested struct list" do
    my_struct = %My.Struct{id: 1, name: "Jan Kowlaski", data: [1, 2, 3, 4, 5, 6, 7, 8, 9]}
    nested_struct_list = %Nested.StructList{id: 1, struct_list: [my_struct]}
    assert {:ok, ^nested_struct_list} = Example.test_nested_struct_list(nested_struct_list)
  end

  # tests for bugged version of functions returning nil.
  # these tests should be removed in unifex v2.0.0. For more information check:
  # https://github.com/membraneframework/membrane_core/issues/758

  test "nil bugged" do
    assert :"" == Example.test_nil_bugged()
  end

  test "nil tuple bugged" do
    assert {:"", 1} == Example.test_nil_tuple_bugged(1)
  end
end
