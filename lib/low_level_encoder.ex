defmodule PDF417.LowLevelEncoder do
  @start_pattern 0x1FEA8
  @stop_pattern 0x3FA29

  import PDF417.Clusters

  def encode(barcode) do
    barcode
    |> make_matrix()
    |> Enum.map(fn row -> [@start_pattern | convert_to_codewords(row)] ++ [@stop_pattern] end)
  end

  defp convert_to_codewords({row, cluster}) do
    Enum.map(row, fn codeword -> map_code_word(cluster, codeword) end)
  end

  defp make_matrix(config = %{columns: columns, codewords: codewords}) do
    total_rows = div(length(codewords), columns)

    codewords
    |> Enum.chunk_every(columns)
    |> Enum.with_index()
    |> Enum.map(fn {row, row_index} ->
      cluster = rem(row_index, 3)

      [left, right] =
        row_indicators(cluster, total_rows, config)
        |> Enum.map(fn ind -> 30 * div(row_index, 3) + ind end)

      {[left | row] ++ [right], cluster}
    end)
  end

  defp row_indicators(cluster, row_count, %{columns: columns, security_level: security_level}) do
    f1 = div(row_count - 1, 3)
    f2 = columns - 1
    f3 = security_level * 3 + rem(row_count - 1, 3)

    case cluster do
      0 -> [f1, f2]
      1 -> [f3, f1]
      2 -> [f2, f3]
    end
  end
end
