class CheckedRecord
  class Arguments
      
    def allowed? value
      @allowed.nil? || @allowed.include?(value)
    end

    def check values
      illegal_values = @allowed ? values - @allowed : []
      @errors << "Illegal arguments #{illegal_values.inspect}, allowed are: #{@allowed.inspect}" unless illegal_values.empty?
      conflicting = values & @exclusive
      @errors << "Conflicting arguments #{conflicting.inspect}, only one of #{@exclusive.inspect} is allowed" if
        conflicting.size > 1
      missing = values & @required
      @errors << "Required argument missing, one of #{@required.inspect} must be provided"  if missing.empty?
    end

    private

    def exclusive values
      @exclusive = values
    end

    def initialize(&blk)
      @allowed   = nil
      @errors    = []
      @exclusive = []
      @required  = []

      instance_eval(&blk) if blk
    end

    def needs required
      @required = required
    end
  end
end
