defmodule PDF417.HighLevelEncoderTest do
  use ExUnit.Case
  alias PDF417.HighLevelEncoder

  describe "encode" do
    test "equals the number of message and padding codewords plus itself" do
      barcode = HighLevelEncoder.encode(%{message: "AB", columns: 6, security_level: 0})
      assert [4 | _rest] = barcode.codewords
    end

    test "adds padding to fill empty columns" do
      barcode =
        HighLevelEncoder.encode(%{message: "NNNNNNNNNNNNNNNN", columns: 8, security_level: 0})

      assert barcode.codewords == [
               14,
               403,
               403,
               403,
               403,
               403,
               403,
               403,
               403,
               900,
               900,
               900,
               900,
               900,
               701,
               132
             ]
    end
  end
end
