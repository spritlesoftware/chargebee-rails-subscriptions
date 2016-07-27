Rails.application.routes.draw do #:nodoc:
  # ChargeBee webhook route
  # This is the default route that the chargebee's webhooks reach the application
  # and can be configured.
  # The default webhook_api_path is +chargebee_rails_event+ - can be configured;
  # and the default webhook_handler (webhook handling controller) is 
  # +chargebee_rails/webhooks+ - can be configured as well.
  post ChargebeeRails.configuration.webhook_api_path => "#{ChargebeeRails.configuration.webhook_handler}#handle_event"
end
