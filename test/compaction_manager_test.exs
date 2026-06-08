defmodule PDF417.CompactionManagerTest do
  use ExUnit.Case
  alias PDF417.CompactionManager

  test "compacts text" do
    compacted = CompactionManager.compact("ABCDE")
    assert compacted == [1, 63, 149]
  end

  describe "compaction mode switching" do
    test "implicitly uses text" do
      assert CompactionManager.compact("A") == [29]
    end

    test "it adds codeword 902 for long numbers" do
      [902 | _rest] = CompactionManager.compact("12345678912345")
    end

    test "adds 900 to switch to text after numbers" do
      assert [902, _, _, _, _, _, 900 | _string_codes] =
               CompactionManager.compact("12345678912345deadbeef")
    end
  end

  describe "byte compaction mode" do
    test "routes the whole message to the byte compactor" do
      assert CompactionManager.compact("abcdef", :byte) ==
               PDF417.ByteCompactor.compact("abcdef")
    end

    test "defaults to auto mode for arity-1 calls" do
      assert CompactionManager.compact("ABCDE") == CompactionManager.compact("ABCDE", :auto)
    end

    test "byte mode differs from auto for the same input" do
      refute CompactionManager.compact("abcdef", :byte) ==
               CompactionManager.compact("abcdef", :auto)
    end
  end
end
