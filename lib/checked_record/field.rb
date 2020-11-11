class CheckedRecord
  class Field
    
    attr_reader :name, :options

    def default
      if options.has_key?(:default)
        yield options[:default]
      end
    end

    def optional?
      options.has_key?(:default)
    end

    def readonly?
      false
    end


    private
    def initialize(name, **kwds)
      @name = name
      @options = kwds
    end
  end
end
