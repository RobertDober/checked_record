class CheckedRecord
  module Types
    module Predefineds
      def constrained_string(*args, **kwds)
        ConstrainedString.new(*args, **kwds)
      end
    end
  end
end

