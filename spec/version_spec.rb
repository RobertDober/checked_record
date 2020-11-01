require_relative "../lib/checked_record/version"
RSpec.describe CheckedRecord::VERSION do
  version = description 
  it {
    expect(version).to eq("0.1.0")
  }
end
