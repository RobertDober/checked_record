Warning[:experimental] = false
class Result
  attr_reader :status, :value
  def deconstruct
    [status, value].freeze
  end

  def ok?
    status == :ok
  end

  def raise!
    return value if ok?
    raise status, value
  end
  class << self
    def new(*,**)
      raise NoMethodError, "only use the constructors `.ok` and `.error`"
    end

    def error(message, error: RuntimeError)
      raise ArgumentError, "#{error.inspect} must be an Exception" unless Exception.class === error
      o = allocate
      o.instance_exec do
        @status = error
        @value  = message
      end
      o.freeze
    end

    def ok(value=nil)
      o = allocate
      o.instance_exec do
        @status = :ok
        @value  = value
      end
      o.freeze
    end
  end
end
