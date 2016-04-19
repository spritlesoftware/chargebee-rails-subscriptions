Rails.application.routes.draw do
  # ChargeBee webhook route
  post ChargebeeRails.configuration.webhook_api_path => "#{ChargebeeRails.configuration.webhook_handler}#handle_event"
end
