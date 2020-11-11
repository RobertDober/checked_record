require_relative "field"
class CheckedRecord
  module SingletonMethods
    def field(name, **kwds)
      raise ArgumentError, "field name needs to be a symbol, not #{name}" unless Symbol === name
      raise ArgumentError, "field :#{name} already defined in #{self}" if __fields__[name]
      __fields__[name] = field = CheckedRecord::Field.new(name, **kwds)
      if field.readonly?
        attr_reader name
      else
        attr_accessor name
      end
    end

    def has_key?(name, access_mode: :read)
      return false unless __fields__.has_key?(name)
      return true if access_mode == :read
      raise ArgumentError, "only legal access modes are :read and :write, not #{access_mode.inspect}" unless
        access_mode == :write
      return !__fields__[name].readonly?
    end

    def positional_new(*values)
      # zipping in the correct order will unfortunately mask missing values
      kwds = values.zip(__fields__.keys).map(&:reverse)
      new(**Hash[kwds])
    end
    
    private
    def __fields__
      @__fields__ ||= {}
    end

    def __check_args_(**kwds)
      errors = {}
        .merge(__check_missing_args_(kwds))
        .merge(__check_spurious_args_(kwds))
        # .merge(__check_constraints_(kwds))
      __raise_argument_error_ errors
    end

    def __check_missing_args_(kwds)
      missing = __fields__
        .values
        .reject(&:optional?)
        .map(&:name) - kwds.keys
      return {} if missing.empty?
      {missing: missing}
    end

    def __check_spurious_args_(kwds)
      spurious = kwds.keys - __fields__.keys
      return {} if spurious.empty?
      {spurious: spurious}
    end

    def __format_errors(errors)
      errors
        .inject([]) do |messages, (type, fields)|
          messages << "#{type}: #{fields.inspect}"
        end.join("\n")
    end

    def __raise_argument_error_(errors)
      return if errors.empty?
      raise ArgumentError, __format_errors(errors)
    end
  end
end
