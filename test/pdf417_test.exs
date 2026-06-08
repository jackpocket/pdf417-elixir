defmodule PDF417Test do
  use ExUnit.Case
  doctest PDF417

  test "greets the world" do
    assert true
  end

  test "compaction: :byte option reaches the compactor through the public API" do
    refute PDF417.encode_to_base64("abcdef", %{compaction: :byte}) ==
             PDF417.encode_to_base64("abcdef")
  end
end
