ChargebeeRails.configure do |config|
  # This will be the default plan when a subscription is not provided with one
  # make sure that this plan exists in your active record model
  # config.default_plan_id = 'your_default_plan_id'
  
  # setup chargebee with your site and api_key
  config.chargebee_site = 'CHARGEBEE_SITE'
  config.chargebee_api_key = 'CHARGEBEE_API_KEY'

  # Webhook related configurations
  # Set the controller name that is used to override the webhook events
  # config.webhook_handler = 'webhook_overriding_controller_name' 

  # Configure your own webhook path for ChargeBee events
  # the default_path is 'chargebee_rails_event'
  # config.webhook_api_path = 'chargebee_rails_event' 

  # Set this as true if you have enabled basic http authentication for your
  # webhook api
  # config.secure_webhook_api = true

  # Set the authentication credentials for securing your webhook api
  # config.webhook_authentication = {user: nil, secret: nil}
end
