defmodule PDF417 do
  @moduledoc """
  The public interface for PDF417. Use #encode/1 or /2 for great goodness.
  """

  alias PDF417.{HighLevelEncoder, LowLevelEncoder, PNGEncoder}

  @default_options %{columns: 4, security_level: 3, message: ""}

  @doc """
  Renders the given message in png image format. Returns iodata that can be written to a file or
  converted to something else.
  ## Options
  * `:columns` - Defaults to 4. The number of columns in your symbol output.
  * `:security_level` - Defaults to 3, which is sufficient for up to 160 data codewords (about 320 characters of text). Every 320 characters, add one level here, up to level 8.
  """
  def encode(message, options \\ %{}) do
    options =
      @default_options
      |> Map.merge(options)
      |> Map.merge(%{message: message})

    HighLevelEncoder.encode(options)
    |> LowLevelEncoder.encode()
    |> PNGEncoder.encode()
  end

  @doc """
  Same as `encode/2`, but takes a file path option, and writes the PNG data to a file you specify
  """
  def encode_to_file(message, file_path, options \\ %{}) do
    {:ok, iodata} = encode(message, options)
    File.write(iodata, file_path)
  end

  @doc """
  Same as `encode/2`, but returns a base64 encoded string.
  """
  def encode_to_base64(message, options \\ %{}) do
    {:ok, iodata} = encode(message, options)
    Base.encode64(IO.iodata_to_binary(iodata))
  end
end
