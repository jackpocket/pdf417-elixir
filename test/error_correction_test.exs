defmodule PDF417.ErrorCorrectionTest do
  use ExUnit.Case
  alias PDF417.ErrorCorrection

  describe "correction_codewords" do
    test "returns expected codewords" do
      data = [5, 453, 178, 121, 239]
      security_level = 1
      codewords = ErrorCorrection.correction_codewords(data, security_level)

      assert codewords == [452, 327, 657, 619]
    end
  end
end
