module ChargebeeRails
  
  class Error < StandardError
    attr_reader :original_error

    def initialize(message=nil, original_error=nil)
      super message
      @original_error = original_error
    end
  end

  class PlanError < Error; end
end
