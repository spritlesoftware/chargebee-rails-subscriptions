# :nodoc: all
module ChargebeeRails
  
  class Error < StandardError
    attr_reader :original_error

    def initialize(message=nil, original_error=nil)
      super message
      @original_error = original_error
    end
  end

  class PlanError < Error
    # Raise this error when the plan is not present in active_record
    def plan_not_found
      "Plan Not Found"
    end

    # Raise this error when the plan is not setup in ChargeBee
    def plan_not_configured
      "Plan Not Configured"
    end
  end

  class UnauthorizedError < Error; end
end
