class CheckedRecord

  class Field

    PredefinedChecks = {
      non_negative_integer: ->(n){ Integer === n && n >= 0},
      positive_integer: ->(n){ Integer === n && n > 0}
    }
    
    attr_reader :name, :options

    def check!(value, &blk)
      _raise_constraint_error!(value)
      blk.() if blk
      true
    end

    def checked?
      !!options[:check]
    end

    def default
      if options.has_key?(:default)
        yield options[:default]
      end
    end

    def optional?
      options.has_key?(:default)
    end

    def readonly?
      !!options[:readonly]
    end


    private
    def initialize(name, **kwds, &blk)
      @name = name
      @options = kwds
      _initialize_checks!(blk)
      _check_default!
    end

    def _check_default!
      return unless options[:default]
      _raise_constraint_error!(options[:default], prefix: "illegal default value")
    end

    def _initialize_checks!(blk)
      raise ArgumentError, "must not provide a checking block and the check: option at the same time" if 
        blk && options[:check]
      options[:check] = blk if blk
      _sanitize_checks! if options[:check]
    end

    def _predefined_checks!
      check = PredefinedChecks.fetch(options[:check]) {_raise_undefined_check!}
      options[:check] = check
    end

    def _sanitize_checks!
      case options[:check]
      when Symbol
        _predefined_checks!
      when Proc
        true
      when Class
        klass = options[:check]
        options[:check] = -> (value) { klass === value }
      else
        raise ArgumentError, "illegal type for a check option #{options[:check].inspect}"
      end
    end

    def _raise_constraint_error!(value, prefix: "illegal value")
      return unless checked? && !options[:check].(value)
      raise ConstraintError, "#{prefix} #{value.inspect} for field #{name.inspect}"
    end

    def _raise_undefined_check
      raise ArgumentError, "undefined check #{options[:check].inspect}\n, predefined: #{PredefinedChecks.keys.join(", ")}"
    end
  end
end
