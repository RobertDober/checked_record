class CheckedRecord
  class Field
    
    attr_reader :name, :options

    def optional?
      options.has_key?(:default) ||
        options[:optional]
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
