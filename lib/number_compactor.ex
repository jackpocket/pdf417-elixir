defmodule PDF417.NumberCompactor do
  def compact(part) do
    ("1" <> part)
    |> String.to_integer()
    |> to_base_900([])
  end

  defp to_base_900(integer, codewords) when integer < 900, do: [integer] ++ codewords

  defp to_base_900(integer, codewords) do
    to_base_900(div(integer, 900), [rem(integer, 900) | codewords])
  end

  def compactable?(part) do
    String.length(part) > 13 && Integer.parse(part) != :error
  end

  def codeword, do: 902
end
