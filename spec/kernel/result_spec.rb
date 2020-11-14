RSpec.describe Result do

  context "construction" do
    context "ok constructor" do
      let(:ok) { described_class.ok(42) }

      it "is ok" do
        expect(ok).to be_ok 
      end

      it "has the correct value" do
        expect( ok.value ).to eq(42)
      end

      it "does not raise" do
        expect{ ok.raise! }.not_to raise_error
      end

      it "is frozen" do
        expect( ok ).to be_frozen
      end
    end

    context "error constructor" do
      let(:message) {string_double("oh no")}

      shared_examples_for "error constructor" do
        it "is not ok" do
          expect( error ).not_to be_ok
        end

        it "raises" do
          expect{ error.raise! }.to raise_error(exception, message)
        end

        it "still is frozen" do
          expect( error ).to be_frozen
        end
      end

      context "default error constructor" do
        let(:exception) { RuntimeError }
        let(:error) { described_class.error(message) }
        it_behaves_like "error constructor"
      end 

      context "custom error constructor" do
        let(:exception) { Class.new(Exception) }
        let(:error) { described_class.error(message, error: exception) }
        it_behaves_like "error constructor"
      end 
    end

    context "constraints" do
      let(:message) {string_double("oh no")}

      it "has no classical constructor" do
        expect{ described_class.new(:ok, "hello") }.to raise_error(NoMethodError, "only use the constructors `.ok` and `.error`")
      end

      it "error needs an exception class" do
        expect{ described_class.error(message, error: RuntimeError.new) }.to raise_error(ArgumentError)
      end
    end
  end
end
