defmodule PDF417.PNGEncoder do
  @moduledoc """
    Takes a grid (matrix) of integers and turns them into a PNG. All the integers in the grid need
    to be 17-digits in base 2, with the exception of the stop character, which per the standard has
    one extra bit.
  """

  @black 0
  @white 255
  @bar_width 5
  @quiet_zone 2 * @bar_width

  def encode(matrix, options \\ %{}) do
    width = width(matrix)
    height = height(matrix)

    {:ok, storage} = start_storage()

    png_options = %{
      size: {width, height},
      mode: {:grayscale, 8},
      call: &save_chunk(storage, &1)
    }

    png = :png.create(Enum.into(options, png_options))

    margin(width)
    |> Enum.each(fn row -> :png.append(png, {:row, row}) end)

    Enum.each(matrix, fn line ->
      data_row = make_row(line)

      1..(4 * @bar_width)
      |> Enum.each(fn _ ->
        :png.append(png, {:row, data_row})
      end)
    end)

    margin(width)
    |> Enum.each(fn row -> :png.append(png, {:row, row}) end)

    :png.close(png)
    release_storage(storage)
  end

  defp width([hd | _tail]) do
    # The stop pattern 0x3fa29 is 18 bits long, so we have an extra bar at the end of the line.
    length(hd) * (17 * @bar_width) + 2 * @quiet_zone + @bar_width
  end

  defp height(matrix), do: length(matrix) * 4 * @bar_width + 2 * @quiet_zone

  defp margin(width) do
    1..@quiet_zone |> Enum.map(fn _ -> map_seq(width, fn _ -> @white end) end)
  end

  defp map_seq(size, callback) do
    if size > 0, do: Enum.map(1..size, fn x -> callback.(x) end), else: []
  end

  defp make_row(line) do
    margin = List.duplicate(@white, @quiet_zone)

    row_data =
      line
      |> Enum.map(fn int -> Integer.digits(int, 2) end)
      |> List.flatten()
      |> convert_to_bars()

    margin ++ row_data ++ margin
  end

  defp convert_to_bars(digits) do
    digits |> Enum.map(fn digit -> make_digit_bar(digit) end) |> List.flatten()
  end

  defp make_digit_bar(digit) do
    case digit do
      1 -> List.duplicate(@black, @bar_width)
      0 -> List.duplicate(@white, @bar_width)
    end
  end

  defp start_storage, do: Agent.start_link(fn -> [] end)

  defp save_chunk(storage, iodata) do
    Agent.update(storage, fn acc -> [acc, iodata] end)
  end

  defp release_storage(storage) do
    iodata = Agent.get(storage, & &1)
    :ok = Agent.stop(storage)
    {:ok, iodata}
  end
end
