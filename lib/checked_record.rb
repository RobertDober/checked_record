require_relative "checked_record/singleton_methods.rb"
class CheckedRecord
    ConstraintError = Class.new(RuntimeError)


  define_singleton_method :inherited do |by|
    by.extend SingletonMethods
  end

  def [](key)
    _raise_key_error!(key, :read)
    instance_variable_get("@#{key}")
  end

  def []=(key, value)
    _raise_key_error!(key, :write)
    instance_variable_set("@#{key}", value)
  end

  def to_h
    @field_descriptions.inject({}) do |res, (k,_)|
      res.merge(k => self[k])
    end
  end

  def values_at(*keys)
    keys.inject([]) do |res, k|
      res << self[k]
    end
  end

  private

  def initialize(**kwds)
    # Check for missing and illegal and constraints 
    self.class.send(:__check_args_, **kwds)
    @field_descriptions = self.class.send(:__fields__)
    _initialize_values(kwds)
  end

  def _initialize_defaults
    @field_descriptions.each do |field_name, field_description|
      field_description.default do |default_value|
        # We rely on the compile time check of default values here,
        # actually an ugly optimization that might burn us if we add more general validation 
        instance_variable_set("@#{field_name}", default_value)
      end
    end
  end

  def _initialize_values(kwds)
    _initialize_defaults
    kwds.each do |name, value|
      _set_field_value(name, value)
    end
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

  def _set_field_value(field_name, value)
    @field_descriptions[field_name].check!(value) do
      instance_variable_set("@#{field_name}", value)
    end
  end

end
