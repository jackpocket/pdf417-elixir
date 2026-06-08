defmodule PDF417.ByteCompactor do
  @moduledoc """
  Compacts arbitrary bytes using PDF417 Byte Compaction mode (ISO 15438).

  Every full group of 6 bytes is read as a 48-bit big-endian integer and
  converted to exactly 5 base-900 codewords (most-significant first, left-padded
  with zeros). A trailing group of 1-5 bytes is emitted as one literal codeword
  per byte. The leading latch codeword is 924 when the byte count is a multiple
  of 6, otherwise 901.
  """

  @latch_byte 924
  @latch_byte_padded 901
  @sixpack_codewords 5

  @doc """
  Returns the codewords for `binary`, including the leading latch codeword.
  An empty binary returns `[]`.
  """
  def compact(""), do: []

  def compact(binary) when is_binary(binary) do
    [latch(binary) | compact_chunks(binary)]
  end

  defp latch(binary) do
    if rem(byte_size(binary), 6) == 0, do: @latch_byte, else: @latch_byte_padded
  end

  defp compact_chunks(<<chunk::binary-size(6), rest::binary>>) do
    encode_full_chunk(chunk) ++ compact_chunks(rest)
  end

  defp compact_chunks(<<>>), do: []

  defp compact_chunks(partial), do: :binary.bin_to_list(partial)

  defp encode_full_chunk(<<value::unsigned-big-integer-size(48)>>) do
    value
    |> Integer.digits(900)
    |> pad_leading(@sixpack_codewords)
  end

  defp pad_leading(digits, size) do
    List.duplicate(0, size - length(digits)) ++ digits
  end
end
