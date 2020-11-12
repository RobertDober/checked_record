class CheckedRecord
  class Error < RuntimeError

    attr_reader :errors

    def add_errors(errors, for_field: :__all)
      errors1 = Array(errors)
      @errors.update(for_field => errors1){ |_, old, new| old + new}
    end

    private
    def initialize(**kwds)
      @errors = kwds
    end
  end
end
