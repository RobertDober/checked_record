RSpec.describe CheckedRecord::Types::Predefineds, type: :type_spec do
  describe :constrained_string do

    context "base case" do
      subject {constrained_string}

      it "a constrained_string w/o any constraints is just a string type" do
        expect( subject === "" ).to be_truthy
        expect( subject.("") ).to be_truthy
        expect( subject.errors ).to be_empty
        expect( subject ).to be_valid
      end

      it "still checks the type" do
        expect( subject.(:not_a_string) ).to be_falsy
        expect( subject === :not_a_string ).to be_falsy
        expect( subject ).not_to be_valid
        expect( subject.errors.first ).to eq(":not_a_string is not a String")
      end
    end

    context "length constraints" do
      subject {constrained_string size: 1..3}

      it "complies" do
        validate(with: "eta")
      end

      it "does not" do
        refute(with: "etat", message: %{illegal length of value "etat"; 4 not in required range 1..3})
      end
    end

    context "min or max" do
      let(:min) { constrained_string(min: 3) }
      let(:max) { constrained_string(max: 3) }
      
      it "might be easier to write min instead of size: min..Float::INFINITY, right" do
        validate(min, with: "hello")
        validate(max, with: "ita")
      end

      it "and then the message changes" do
        refute(min, with: "", message: %{illegal length of value ""; 0 < than minimum 3})
        refute(max, with: "hello", message: %{illegal length of value "hello"; 5 > than maximum 3})
      end
    end

    context "protection agains impossible size constraints" do
      it "shall not be empty" do
        expect{ constrained_string(size: 1..0) }.to raise_error(ArgumentError, %r{size must not be an empty range}) 
      end
      it "min shall not exceed max" do
        expect{ constrained_string(min: 10, max: 9) }.to raise_error(ArgumentError, %r{min\(10\) must not exceed max\(9\)}) 
      end
    end

    context "min, max and size conflicts" do
      let(:expected_message) { "must not combine min or max with size"  }
      
      it "size and min" do
        expect{ constrained_string(size: 1..2, min: 1) }.to raise_error(ArgumentError, expected_message)
      end
      it "size and max" do
        expect{ constrained_string(size: 1..2, max: 1) }.to raise_error(ArgumentError, expected_message)
      end
    end

    context "general regex match" do
      subject {constrained_string(match: %r{ab*a}i)}

      it "matches just fine" do
        validate(with: "Abba")
      end

      it "there is no account for taste" do
        refute(with: "Beatles",message: "value \"Beatles\" does not match required rgx /ab*a/i" )
      end
    end

    context "prefix and suffix" do
      let(:prefix) { constrained_string(prefix: "A" ) }
      let(:suffix) { constrained_string(suffix: "a" ) }

      it "prefix" do
        validate(prefix, with: "Alpha")
        refute(prefix, with: "Beta", message: %{value "Beta" does not start with "A"})
      end

      it "suffix" do
        validate(suffix, with: "Delta")
        refute(suffix, with: "Epsilon", message: %{value "Epsilon" does not end with "a"})
      end
      
      it "they must be strings" do
        expect{ constrained_string(prefix: /./) }.to raise_error(ArgumentError, "prefix must be a string")
        expect{ constrained_string(suffix: /./) }.to raise_error(ArgumentError, "suffix must be a string")
      end
    end

    context "some convenience checkers" do
      context "lowercase" do
        subject {constrained_string :lowercase}
        it {
          validate(with: "hello")
          validate(with: "")
          refute(with: "Hello", message: %{value "Hello" is not lowercase})
        }
      end
      context "uppercase" do
        subject {constrained_string :uppercase}
        it {
          validate(with: "HELLO")
          validate(with: "")
          refute(with: "Hello", message: %{value "Hello" is not uppercase})
        }
      end
      context "Capitalized" do
        subject {constrained_string :capitalized}
        it {
          validate(with: "Hello")
          refute(with: "", message: %{value "" is not capitalized})
          refute(with: "HEllo", message: %{value "HEllo" is not capitalized})
        }
      end
    end
  end
end
