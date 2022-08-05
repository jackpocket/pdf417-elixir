defmodule PDF417.NumberCompactor do
  @moduledoc """
  Converts numbers to compacted form, as an array of base 900 digits
  """
  def compact(part) do
    ("1" <> part)
    |> String.to_integer()
    |> Integer.digits(900)
  end

  def compactable?(part) do
    String.length(part) > 13 && Integer.parse(part) != :error
  end

  def codeword, do: 902
end
