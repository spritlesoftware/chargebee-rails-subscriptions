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
    attr_accessor :end_of_term
    attr_accessor :include_delayed_charges

    def initialize
      @default_plan_id = nil
      @end_of_term = false
      @include_delayed_charges = {changes_estimate: false, renewal_estimate: true}
    end
  end
end
