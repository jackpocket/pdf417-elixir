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
end
