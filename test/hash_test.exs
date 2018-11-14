defmodule Shortler.HashTest do
  use ExUnit.Case, async: true
  doctest Shortler
  alias Shortler.Hash

  describe "hash" do
    test "should raise when passing non-strings values" do
      assert_raise FunctionClauseError, fn ->
        Hash.hash(123)
      end

      assert_raise FunctionClauseError, fn ->
        Hash.hash(['a', 'b', 'c'])
      end

      assert_raise FunctionClauseError, fn ->
        Hash.hash(:abc)
      end
    end

    test "should successfully return the 7 chars size value of a given string" do
      assert Hash.hash("abc") == "Zk-NkcGgWq6"
    end
  end
end
