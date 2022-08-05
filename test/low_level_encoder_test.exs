defmodule PDF417.LowLevelEncoderTest do
  use ExUnit.Case
  alias PDF417.LowLevelEncoder
  alias PDF417.HighLevelEncoder

  describe "encode" do
    test "it returns an array of the correct symbols" do
      config = %{message: "this is a test", columns: 4, security_level: 1}

      encoded =
        config
        |> HighLevelEncoder.encode()
        |> LowLevelEncoder.encode()

      assert encoded ==
               [
                 [130_728, 125_680, 110_016, 69_008, 75_288, 100_396, 120_032, 260_649],
                 [130_728, 128_304, 104_412, 126_842, 96_414, 119_170, 129_720, 260_649],
                 [130_728, 109_040, 96_460, 102_290, 102_290, 102_290, 109_040, 260_649],
                 [130_728, 89_720, 122_264, 124_350, 118_172, 113_056, 89_980, 260_649]
               ]
    end
  end
end
