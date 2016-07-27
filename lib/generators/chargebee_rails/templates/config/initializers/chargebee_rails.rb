ChargebeeRails.configure do |config|
  # This will be the default plan when a subscription is not provided with one
  # make sure that this plan exists in your active record model
  # config.default_plan_id = 'your_default_plan_id'

  # Specify the default end of term value for subscription related changes like 
  # subscription updation and cancellation. Setting this as true will make the 
  # changes for subscription at end of term or at next renewal. Reference - 
  # https://apidocs.chargebee.com/docs/api/subscriptions#update_a_subscription
  # config.end_of_term = false

  # Set default proration for subscription related changes Reference - 
  # https://apidocs.chargebee.com/docs/api/subscriptions#update_a_subscription
  # config.proration = true

  # Configure the default behavior of including delayed charges while estimating
  # Reference - https://apidocs.chargebee.com/docs/api/estimates#update_subscription_estimate
  # config.include_delayed_charges = { changes_estimate: false, renewal_estimate: true }
  
  # setup chargebee with your site and api_key
  config.chargebee_site = 'CHARGEBEE_SITE'
  config.chargebee_api_key = 'CHARGEBEE_API_KEY'

  # Webhook related configurations
  # Set the controller name that is used to override the webhook events
  # config.webhook_handler = 'webhook_overriding_controller_name' 

  # Configure your own webhook path for ChargeBee events
  # the default_path is 'chargebee_rails_event'
  # config.webhook_api_path = 'your_webhook_path'

  # Set this as true if you have enabled basic http authentication for your
  # webhook api
  # config.secure_webhook_api = true

  # Set the authentication credentials for securing your webhook api
  # config.webhook_authentication = {user: nil, secret: nil}
end
