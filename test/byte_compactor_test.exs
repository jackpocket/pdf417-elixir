defmodule PDF417.ByteCompactorTest do
  use ExUnit.Case, async: true
  alias PDF417.ByteCompactor

  test "empty binary produces no codewords" do
    assert ByteCompactor.compact("") == []
  end

  test "latch is 901 when the byte count is not a multiple of 6" do
    assert [901 | _] = ByteCompactor.compact("abc")
  end

  test "latch is 924 when the byte count is a multiple of 6" do
    assert [924 | _] = ByteCompactor.compact("abcdef")
  end

  test "one to five trailing bytes are emitted as literal codewords" do
    assert ByteCompactor.compact("abc") == [901, 97, 98, 99]
    assert ByteCompactor.compact("abcde") == [901, 97, 98, 99, 100, 101]
  end

  test "a full six-byte chunk becomes five base-900 codewords" do
    assert ByteCompactor.compact("abcdef") == [924, 163, 179, 507, 603, 522]
  end

  test "sixpack codewords are left-padded to five (leading zeros preserved)" do
    assert ByteCompactor.compact(<<0, 0, 0, 0, 0, 0>>) == [924, 0, 0, 0, 0, 0]
    assert ByteCompactor.compact(<<0, 0, 0, 0, 0, 1>>) == [924, 0, 0, 0, 0, 1]
    # value 900 -> base-900 digits [1, 0] -> padded [0, 0, 0, 1, 0]
    assert ByteCompactor.compact(<<0, 0, 0, 0, 3, 132>>) == [924, 0, 0, 0, 1, 0]
  end

  test "a full chunk plus trailing bytes uses the padded latch" do
    assert ByteCompactor.compact("abcdefg") == [901, 163, 179, 507, 603, 522, 103]
  end
end
