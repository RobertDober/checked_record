require_relative "checked_record/field"
class CheckedRecord

  define_singleton_method :field do |name, **kwds|
    raise ArgumentError, "field name needs to be a symbol, not #{name}" unless Symbol === name
    raise ArgumentError, "field :#{name} already defined" if __fields__[name]
    __fields__[name] = field = CheckedRecord::Field.new(name, **kwds)
    if field.readonly?
      attr_reader name
    else
      attr_accessor name
    end
  end

  private

  def initialize(**kwds)
    # Check for missing and illegal and constraints 
    errors = self.class.__check_args_(**kwds)
    raise ArgumentError, self.class.__format_errors_(errors) unless errors.empty?
  end

  define_singleton_method :__fields__ do ||
    @__fields__ ||= {}
  end

  define_singleton_method :__check_args_ do |**kwds|
    missing = {}
      .merge(__check_missing_args_(kwds))
      .merge(__check_forbidden_args_(kwds))
      .merge(__check_constraints_(kwds))
    
  end

  define_singleton_method :__format_errors do |errors|
    errors
      .inject([]) do |messages, (type, fields)|
        if fields.empty?
          messages
        else
          messages << "#{type}: #{fields.inspect}"
        end
      end
      .join("\n")
  end
end
