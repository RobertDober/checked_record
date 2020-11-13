class CheckedRecord
  module Types
    class AbstractType

      def add_error(message)
        errors << message
        false
      end

      def errors
        @__errors__ ||= []
      end

      def valid?
        errors.empty?
      end

      private

      def initialize(*, **)
        raise RuntimeError, "I am (#{self.class}) abstract"
      end

    end
  end
end
