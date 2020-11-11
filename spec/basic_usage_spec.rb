
RSpec.describe CheckedRecord do
  class BasicRecord < CheckedRecord
    field :a
    field :b
  end
  context "Basic Usage" do
    it "needs keywords for each undefaulted field in the constructor" do
      BasicRecord.new(a: 1, b:2)
      expect{ BasicRecord.new(a: 1) }.to raise_error(ArgumentError, %{missing: [:b]})
    end
    it "does not accept spurious keywords" do
      expect{ BasicRecord.new(a: 1, b: 2, c: 3) }.to raise_error(ArgumentError, %{spurious: [:c]})
    end
  end
end
