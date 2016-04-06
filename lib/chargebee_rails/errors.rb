module ChargebeeRails
  
  class Error < StandardError
    attr_reader :original_error

    def initialize(message=nil, original_error=nil)
      super message
      @original_error = original_error
    end
  end

  class PlanError < Error
    def plan_not_found
      "Plan Not Found"
    end

    def plan_not_configured
      "Plan Not Configured"
    end
  end
end
