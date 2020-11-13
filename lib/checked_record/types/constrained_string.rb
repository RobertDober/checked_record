
class CheckedRecord
  module Types
    class ConstrainedString < AbstractType

      LegalFlags = %i[
        capitalized lowercase uppercase
      ]

      Capitalized =%r{\A[[:upper:]][[:lower:]]*\z}
      LowerCase = %r{\A[[:lower:]]*\z}
      UpperCase = %r{\A[[:upper:]]*\z}

      def ===(subject)
        return unless _check_type(subject)
        _check_size(subject)
        _check_min(subject)
        _check_max(subject)
        _check_match(subject)
        _check_prefix(subject)
        _check_suffix(subject)
        _check_flags(subject)
        valid?
      end
      alias_method :call, :===


      private

      def _check_flag_capitalized(subject)
        return if Capitalized === subject
        add_error("value #{subject.inspect} is not capitalized")
      end

      def _check_flag_lowercase(subject)
        return if LowerCase === subject
        add_error("value #{subject.inspect} is not lowercase")
      end

      def _check_flag_uppercase(subject)
        return if UpperCase === subject
        add_error("value #{subject.inspect} is not uppercase")
      end

      def _check_flags(subject)
        @flags.each do |flag|
          send "_check_flag_#{flag}", subject
        end
      end

      def _check_match(subject)
        return unless @match
        return if @match === subject
        add_error(
          "value #{subject.inspect} does not match required rgx #{@match.inspect}")
      end

      def _check_max(subject)
        return unless @max
        return if subject.length <= @max
        add_error(
          "illegal length of value #{subject.inspect}; #{subject.length} > than maximum #{@max}")
      end

      def _check_min(subject)
        return unless @min
        return if subject.length >= @min
        add_error(
          "illegal length of value #{subject.inspect}; #{subject.length} < than minimum #{@min}")
      end

      def _check_prefix(subject)
        return unless @prefix
        return if subject.start_with?(@prefix)
        add_error(
          "value #{subject.inspect} does not start with #{@prefix.inspect}")

      end

      def _check_size(subject)
        return unless @size
        return if @size === subject.length
        add_error(
          "illegal length of value #{subject.inspect}; #{subject.length} not in required range #{@size}")
      end

      def _check_suffix(subject)
        return unless @suffix
        return if subject.end_with?(@suffix)
        add_error(
          "value #{subject.inspect} does not end with #{@suffix.inspect}")

      end

      def _check_type(subject)
        String === subject || add_error("#{subject.inspect} is not a String")
      end

      def _raise_flags_argument_error(illegal_flags)
        return if illegal_flags.empty?
        raise ArgumentError, "Illegal flags #{illegal_flags.inspect}, legal flags are: #{LegalFlags.inspect})"
      end

      def _set_flags(flags)
        illegal_flags = flags - LegalFlags
        _raise_flags_argument_error(illegal_flags)
        @flags = Set.new(flags)
      end


      def _set_match(match)
        raise ArgumentError,"match argument needs to be a Regexp" unless match.nil?||(Regexp===match)
        @match = match
      end

      def _set_prefix(prefix)
        raise ArgumentError, "prefix must be a string" unless prefix.nil? || String === prefix
        @prefix = prefix
      end

      def _set_size(size, min, max)
        raise ArgumentError, "must not combine min or max with size" if size && (min || max)
        raise ArgumentError, "size must not be an empty range" if size && size.size < 1
        raise ArgumentError, "min(#{min}) must not exceed max(#{max})" if min && max && min > max
        @size = size
        @min  = min
        @max  = max
      end

      def _set_suffix(suffix)
        raise ArgumentError, "suffix must be a string" unless suffix.nil? || String === suffix
        @suffix = suffix
      end

      def initialize(*flags, size: nil, min: nil, max: nil, match: nil, prefix: nil, suffix: nil)
        _set_flags(flags)
        _set_size(size, min, max)
        _set_match(match)
        _set_prefix(prefix)
        _set_suffix(suffix)
      end

    end
  end
end
