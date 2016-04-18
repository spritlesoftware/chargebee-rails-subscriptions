Rails.application.routes.draw do
  # ChargeBee webhook route
  post ChargebeeRails.configuration.webhook_api_path => 'webhooks#handle_event'
end
