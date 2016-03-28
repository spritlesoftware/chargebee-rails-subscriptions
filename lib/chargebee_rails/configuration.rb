module ChargebeeRails

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configuration=(config)
    @configuration = config
  end

  def self.configure
    yield configuration
  end

  class Configuration
    attr_accessor :default_plan_id

    def initialize
      @default_plan_id = 'default-plan'
    end
  end
end
