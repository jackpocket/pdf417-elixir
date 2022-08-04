defmodule PDF417.TextCompactor do
  @submodes %{
    "UPP" =>
      "ABCDEFGHIJKLMNOPQRSTUVWXYZ\s" |> String.graphemes() |> Enum.with_index() |> Map.new(),
    "LOW" =>
      "abcdefghijklmnopqrstuvwxyz\s" |> String.graphemes() |> Enum.with_index() |> Map.new(),
    "MIX" =>
      "0123456789&\r\t,:#-.$/+%*=^" |> String.graphemes() |> Enum.with_index() |> Map.new(),
    "PUN" =>
      ";<>@[\\]_`~!\r\t,:\n-.$/\"|*()?{}'" |> String.graphemes() |> Enum.with_index() |> Map.new()
  }

  @jump_commands %{
    "UPP" => %{
      "LOW" => [27],
      "MIX" => [28],
      "PUN" => [28, 25]
    },
    "LOW" => %{
      "UPP" => [28, 28],
      "MIX" => [28],
      "PUN" => [28, 25]
    },
    "MIX" => %{
      "LOW" => [27],
      "UPP" => [28],
      "PUN" => [25]
    },
    "PUN" => %{
      "LOW" => [29, 27],
      "UPP" => [29],
      "MIX" => [29, 28]
    }
  }

  def compact(part) do
    compact_text(part)
    |> Enum.chunk_every(2)
    |> Enum.map(fn pair -> convert_codepoint_pair(pair) end)
  end

  defp convert_codepoint_pair([left, right]) do
    left * 30 + right
  end

  defp convert_codepoint_pair([left]) do
    left * 30 + pad_codepoint()
  end

  def compactable?(part) do
    Regex.match?(~r/[\x09\x0a\x0d\x20-\x7e]/, part)
  end

  def compact_text(part) do
    part
    |> String.graphemes()
    |> get_codepoints("UPP", [])
  end

  def codeword, do: 900

  defp get_codepoints([], _submode, codepoints), do: codepoints

  defp get_codepoints([character | character_array], current_submode, codepoints) do
    submode = next_submode(character, current_submode)
    codepoints = jump_submode(current_submode, submode, codepoints)

    get_codepoints(
      character_array,
      submode,
      codepoints ++ [get_in(@submodes, [submode, character])]
    )
  end

  defp next_submode(char, preferred_submode) do
    options =
      Enum.reduce(@submodes, [], fn {mode, list}, acc ->
        if Map.has_key?(list, char) do
          [mode | acc]
        else
          acc
        end
      end)

    if Enum.member?(options, preferred_submode) do
      preferred_submode
    else
      hd(options)
    end
  end

  defp jump_submode(a, b, codepoints) when a == b, do: codepoints

  defp jump_submode(current, new, codepoints) do
    codepoints ++ get_in(@jump_commands, [current, new])
  end

  defp pad_codepoint, do: 29
end
