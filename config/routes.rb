Rails.application.routes.draw do
  # ChargeBee webhook route
  post ChargebeeRails.configuration.webhook_api_path => 'chargebee_rails/webhooks#handle_event'
end
