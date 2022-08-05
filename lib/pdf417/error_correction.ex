defmodule PDF417.ErrorCorrection do
  import PDF417.ReedSolomon, only: [factors: 0]

  def correction_codewords(codewords, security_level) do
    coefficients = Enum.at(factors(), security_level)
    error_codewords = List.duplicate(0, length(coefficients))

    codewords
    |> Enum.reduce(error_codewords, fn codeword, int_error_cw ->
      t1 = rem(codeword + List.last(int_error_cw), 929)

      int_error_cw =
        (length(int_error_cw) - 1)..1
        |> Enum.reduce(int_error_cw, fn j, acc ->
          t2 = rem(t1 * Enum.at(coefficients, j), 929)
          t3 = 929 - t2
          val = (Enum.at(acc, j - 1) + t3) |> rem(929)

          List.replace_at(acc, j, val)
        end)

      first_ecw = 929 - rem(t1 * Enum.at(coefficients, 0), 929)

      List.replace_at(int_error_cw, 0, first_ecw)
    end)
    |> Enum.map(fn correction -> check_zero(correction) end)
    |> Enum.reverse()
  end

  defp check_zero(0), do: 0
  defp check_zero(n), do: 929 - n
end
