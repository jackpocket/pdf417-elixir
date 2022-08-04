defmodule PDF417.HighLevelEncoder do
  alias PDF417.{CompactionManager, ErrorCorrection}

  @pad_codeword 900

  def encode(barcode = %{message: message, columns: columns, security_level: security_level}) do
    codewords =
      CompactionManager.compact(message)
      |> padding(security_level, columns)
      |> add_length_descriptor()
      |> error_correction(security_level)

    Map.put(barcode, :codewords, codewords)
  end

  defp padding(codewords, security_level, columns) do
    sum_codewords = 1 + length(codewords) + correction_codeword_length(security_level)

    rows = :math.ceil(sum_codewords / columns)

    pad_count =
      (rows * columns - sum_codewords)
      |> trunc()

    codewords ++ List.duplicate(@pad_codeword, pad_count)
  end

  defp correction_codeword_length(security_level), do: :math.pow(2, security_level + 1)

  defp add_length_descriptor(codewords) do
    [1 + length(codewords) | codewords]
  end

  defp error_correction(codewords, security_level) do
    codewords ++ ErrorCorrection.correction_codewords(codewords, security_level)
  end
end
