# :nodoc: all
module ChargebeeRails

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.setup
    ::ChargeBee.configure(
      site: configuration.chargebee_site, 
      api_key: configuration.chargebee_api_key
    )
  end

  def self.configure
    yield configuration
    setup
  end

  class Configuration
    attr_accessor :default_plan_id
    attr_accessor :end_of_term
    attr_accessor :proration
    attr_accessor :include_delayed_charges
    attr_accessor :chargebee_site
    attr_accessor :chargebee_api_key
    attr_accessor :currency
    attr_accessor :webhook_handler
    attr_accessor :webhook_api_path
    attr_accessor :secure_webhook_api
    attr_accessor :webhook_authentication

    def initialize
      @default_plan_id = nil
      @end_of_term = false
      @proration = true
      @include_delayed_charges = {changes_estimate: false, renewal_estimate: true}
      @webhook_handler = 'chargebee_rails/webhooks'
      @webhook_api_path = 'chargebee_rails_event'
      @secure_webhook_api = false
      @webhook_authentication = {user: nil, secret: nil}
      @chargebee_site = nil
      @chargebee_api_key = nil
      @currency = "US Dollars [USD]"
    end
  end
end
