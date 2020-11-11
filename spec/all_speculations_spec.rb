require "speculate_about"
RSpec.describe "Speculations" do
  context "main speculation" do
    speculate_about "README.md"
  end
  context "detailed speculations" do
    speculate_about "./speculations/**/*.md"
  end
end
