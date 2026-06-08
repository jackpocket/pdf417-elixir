defmodule PDF417.ByteCompactorTest.Decoder do
  @moduledoc false
  # Test-only inverse of PDF417.ByteCompactor.compact/1.

  def decode([]), do: ""
  def decode([924 | codewords]), do: from_sixpacks(codewords, [])
  def decode([901 | codewords]), do: from_padded(codewords)

  defp from_sixpacks([], acc), do: acc |> Enum.reverse() |> IO.iodata_to_binary()

  defp from_sixpacks([a, b, c, d, e | rest], acc) do
    value = (((a * 900 + b) * 900 + c) * 900 + d) * 900 + e
    from_sixpacks(rest, [<<value::unsigned-big-integer-size(48)>> | acc])
  end

  defp from_padded(codewords) do
    # 901 latch => 1-5 trailing literal bytes, so this floor-divide recovers
    # the number of full 6-byte chunks (each encoded as 5 sixpack codewords).
    full_chunks = div(length(codewords) - 1, 5)
    {sixpack_cws, literal_cws} = Enum.split(codewords, full_chunks * 5)
    from_sixpacks(sixpack_cws, []) <> IO.iodata_to_binary(literal_cws)
  end
end

defmodule PDF417.ByteCompactorTest do
  use ExUnit.Case, async: true
  alias PDF417.ByteCompactor
  alias PDF417.ByteCompactorTest.Decoder

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

  describe "round-trip" do
    test "byte compaction reversibly preserves a HUB3 message with diacritics" do
      message =
        Enum.join(
          [
            "HRVHUB30",
            "HRK",
            "000000000012355",
            "ŽELJKO SENEKOVIĆ",
            "IVANEČKA ULICA 125",
            "42000 VARAŽDIN",
            "2DBK d.d.",
            "ALKARSKI PROLAZ 13B",
            "21230 SINJ",
            "HR1210010051863000160",
            "HR01",
            "7269-68949637676-00019",
            "COST",
            "Troškovi za 1. mjesec"
          ],
          "\n"
        )

      decoded =
        message
        |> ByteCompactor.compact()
        |> Decoder.decode()

      assert decoded == message
      assert decoded =~ "VARAŽDIN"
      assert decoded =~ "SENEKOVIĆ"

      assert "" |> ByteCompactor.compact() |> Decoder.decode() == ""
    end
  end
end
