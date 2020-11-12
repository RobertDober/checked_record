require_relative "checked_record/singleton_methods.rb"
require_relative "checked_record/error.rb"
class CheckedRecord
    ConstraintError = Class.new(RuntimeError)


  define_singleton_method :inherited do |by|
    by.extend SingletonMethods
  end

  def [](key)
    _raise_key_error!(key, :read)
    instance_variable_get("@#{key}")
  end

  def []=(field_name, value)
    _raise_key_error!(field_name, :write)
    instance_variable_set("@#{field_name}", value)
    errors = _validate_field(field_name)
    return value if errors.empty?
    raise ConstraintError, _format_errors(field_name => errors)
  end

  def merge(other=nil, **kwds)
  end

  def merge!(other=nil, **kwds)
    status, result = merge(other, **kwds)
    case status
    when :ok
      result
    end
  end

  def to_h
    @__field_descriptions.inject({}) do |res, (k,_)|
      res.merge(k => self[k])
    end
  end

  def values_at(*keys)
    keys.inject([]) do |res, k|
      res << self[k]
    end
  end

  private

  def _format_errors(errors)
    errors
      .map{ |field, field_errors| _format_field_errors(field, field_errors) }
      .join("\n")
  end

  def _format_field_errors(field, field_errors)
    field_errors
      .join("\n")
  end

  def _initialize_defaults
    @__field_descriptions.each do |field_name, field_description|
      field_description.default do |default_value|
        # We rely on the compile time check of default values here,
        # actually an ugly optimization that might burn us if we add more general validation 
        instance_variable_set("@#{field_name}", default_value)
      end
    end
  end

  def _initialize_values(kwds)
    errors = []
    _initialize_defaults
    kwds.each do |name, value|
      _set_field_value(name, value, errors)
    end
    return true if errors.empty?
    raise ConstraintError, errors.join("\n")
  end

  def _key_error_message(key, access_mode)
    case access_mode
    when :read
      "undefined field #{key}"
    else
      "must not modify readonly field #{key.inspect}"
    end
    
  end

  def _raise_key_error!(key, access_mode)
    return if self.class.has_key?(key, access_mode: access_mode)
    raise KeyError, _key_error_message(key, access_mode)
  end

  def _set_field_value(field_name, value, errors)
    @__field_descriptions[field_name].check!(value, errors) do
      instance_variable_set("@#{field_name}", value)
    end
  end

  def _validate_record!
    errors = _validate_all_fields
    return if errors.empty?
    raise ConstraintError, _format_errors(errors)
  end

  def _validate_all_fields
    already_run = Set.new
    @__field_descriptions.inject({}) do |errors, (field_name, _)|
      these_errors = _validate_field(field_name, already_run)
      if these_errors.empty?
        errors
      else
        errors.merge(field_name => these_errors)
      end 
    end
  end

  def _validate_field(field_name, already_run=Set.new)
    @__validations[field_name]
      .map do |validation|
        unless already_run.member?(validation)
          already_run << validation
          send(validation)
        end
    end.compact
  end

  def initialize(**kwds)
    # Check for missing and illegal and constraints 
    self.class.send(:__check_args_, **kwds)
    @__field_descriptions = self.class.send(:__fields__)
    @__validations = self.class.send(:__validations__)
    _initialize_values(kwds)
    _validate_record!
  end

end
