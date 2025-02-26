defmodule PDF417.NumberCompactorTest do
  use ExUnit.Case
  alias PDF417.NumberCompactor

  describe "compact" do
    test "prepends 1 to groups of numbers" do
      assert NumberCompactor.compact("90") == [190]
    end

    test "converts to base 900" do
      # prepend 1 to 923, get 1923, so that's 2*900 + 123
      assert NumberCompactor.compact("923") == [2, 123]
      assert NumberCompactor.compact("2345678912345") == [18, 735, 78, 813, 645]
    end
  end

  describe "compactible" do
    test "returns true for parseable integers longer than 13 digits" do
      assert NumberCompactor.compactable?("12345678912345")
    end

    test "returns false for short strings" do
      refute NumberCompactor.compactable?("asdf")
    end

    test "returns false for long strings" do
      refute NumberCompactor.compactable?("stringgreaterthanthirteencharacters")
    end

    test "returns false for strings that does not represent a number" do
      refute NumberCompactor.compactable?("123abcdefghijkl")
    end

    test "returns false for short numbers" do
      refute NumberCompactor.compactable?("123")
    end
  end
end
