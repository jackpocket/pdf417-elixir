defmodule PDF417.CompactionManager do
  alias PDF417.{NumberCompactor, TextCompactor}

  def compact(message) do
    message
    |> String.split(~r/[0-9]{13,44}/, include_captures: true)
    |> Enum.filter(fn s -> s != "" end)
    |> get_compactor_and_compact([])
  end

  def get_compactor_and_compact(parts, compacted, old_compactor \\ TextCompactor)
  def get_compactor_and_compact([], compacted, _old_compactor), do: compacted

  def get_compactor_and_compact([part | rest], compacted, old_compactor) do
    compactor =
      Enum.find(compactors(), fn c ->
        c.compactable?(part)
      end)

    new = compacted ++ mode_switch(old_compactor, compactor) ++ compactor.compact(part)
    get_compactor_and_compact(rest, new, compactor)
  end

  def compactors do
    [
      NumberCompactor,
      TextCompactor
    ]
  end

  defp mode_switch(a, b) when a == b, do: []
  defp mode_switch(_a, b), do: [b.codeword()]
end
