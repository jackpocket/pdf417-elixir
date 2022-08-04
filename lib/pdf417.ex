defmodule PDF417 do
  @moduledoc """
  Documentation for `PDF417`.
  """

  alias PDF417.{HighLevelEncoder, LowLevelEncoder}

  @default_options %{columns: 4, security_level: 3, message: "", starts_binary: false}

  def encode(message, opts \\ %{}) do
    options =
      @default_options
      |> Map.merge(opts)
      |> Map.merge(%{message: message})

    HighLevelEncoder.encode(options)
    |> LowLevelEncoder.encode()
  end
end
