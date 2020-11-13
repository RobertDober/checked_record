module Support
  module TypeHelper
    def refute(checker=nil, with:, message: nil)
      checker ||= subject
      expect(checker.(with)).to be_falsy
      expect( checker ).not_to be_valid
      if message
        expect( checker.errors ).to be_include(message)
      end
    end

    def validate(checker=nil, with:)
      checker ||= subject
      expect(checker.(with)).to be_truthy
      expect( checker ).to be_valid
    end
  end
end
RSpec.configure do |cfg|
  cfg.include CheckedRecord::Types::Predefineds, type: :type_spec
  cfg.include Support::TypeHelper, type: :type_spec
end
