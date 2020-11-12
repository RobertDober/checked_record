class CheckedRecord

  class Field

    PredefinedChecks = {
      int: ->(n) {Integer === n},
      non_negative_int: ->(n){ Integer === n && n >= 0},
      positive_int: ->(n){ Integer === n && n > 0},
      string: ->(s) {String === s},
      sym: ->(s) {Symbol === s},
    }
    
    attr_reader :name, :options

    def check!(value, errors=nil, &blk)
      _raise_constraint_error!(value, errors: errors)
      blk.() if blk
      errors.nil? || errors.empty?
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
      raise ArgumentError, "must not provide the ceck: and type: option at the same time" if options[:check] && options[:type]
      options[:check] = options.delete(:type) if options[:type]
      raise ArgumentError, "must not provide a checking block and the check: option at the same time" if 
        blk && options[:check]
      options[:check] = blk if blk
      _sanitize_checks! if options[:check]
    end

    def _make_readable_predefined_list
      PredefinedChecks
        .keys
        .sort
        .group_by{|predef| predef[0]}
        .values
        .map{|predef| predef.map(&:inspect).join(", ")}
        .join("\n            ")
    end

    def _predefined_checks!
      check = PredefinedChecks.fetch(options[:check]) {_raise_undefined_check!}
      options[:check] = check
    end

    def _raise_constraint_error!(value, errors: nil, prefix: "illegal value")
      return unless checked? && !options[:check].(value)
      message =  "#{prefix} #{value.inspect} for field #{name.inspect}"
      case errors
      when Array
        errors <<  message
      else
        raise ConstraintError, message
      end
    end

    def _raise_undefined_check!
      raise ArgumentError, "undefined check #{options[:check].inspect}\npredefined: #{_readable_predefined_list}"
    end

    def _readable_predefined_list
      @__readable_predefined_list__ ||= _make_readable_predefined_list
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

  end
end
