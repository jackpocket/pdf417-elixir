defmodule TextCompactorTest do
  use ExUnit.Case
  alias PDF417.TextCompactor

  describe "compact" do
    test "turns codepoints into codwords" do
      assert TextCompactor.compact("AB") == [1]
    end

    test "pads incomplete codewords" do
      assert TextCompactor.compact("ABC") == [1, 89]
    end
  end

  describe "compact_text/1 from uppercase" do
    test "uses uppercase as the implicit submode" do
      assert TextCompactor.compact_text("J") == [9]
    end

    test "uses jump commands to change submode" do
      assert TextCompactor.compact_text("@Tq5") == [28, 25, 3, 29, 19, 27, 16, 28, 5]
    end

    test "jumps to lower" do
      assert TextCompactor.compact_text("Zy") == [25, 27, 24]
    end

    test "jumps to mixed" do
      assert TextCompactor.compact_text("G&") == [6, 28, 10]
    end

    test "jumps to punctuation" do
      assert TextCompactor.compact_text("N?") == [13, 28, 25, 25]
    end

    test "does not code a jump command when the submode is the same" do
      assert TextCompactor.compact_text("XYZ") == [23, 24, 25]
    end
  end

  describe "compact_text from lowercase" do
    test "jumps to uppercases" do
      assert TextCompactor.compact_text("yZ") == [27, 24, 28, 28, 25]
    end

    test "jumps to mixed" do
      assert TextCompactor.compact_text("f0") == [27, 5, 28, 0]
    end

    test "jumps to punctuation" do
      assert TextCompactor.compact_text("m{") == [27, 12, 28, 25, 26]
    end

    test "does not code a jump command when the submode is the same" do
      assert TextCompactor.compact_text("ijk") == [27, 8, 9, 10]
    end
  end

  describe "compact_text from mixed" do
    test "jumps to uppercases" do
      assert TextCompactor.compact_text("5A") == [28, 5, 28, 0]
    end

    test "jumps to lowercase" do
      assert TextCompactor.compact_text("=u") == [28, 23, 27, 20]
    end

    test "jumps to punctuation" do
      assert TextCompactor.compact_text("#>") == [28, 15, 25, 2]
    end

    test "does not code a jump command when the submode is the same" do
      assert TextCompactor.compact_text("987") == [28, 9, 8, 7]
    end
  end

  describe "compactable?" do
    test "returns true for ASCII characters" do
      assert TextCompactor.compactable?("this is a test")
    end

    test "returns false for non-ascii binaries" do
      refute TextCompactor.compactable?("👾👾👾👾👾👾👾👾")
    end
  end
end
