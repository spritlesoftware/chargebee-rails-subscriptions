# Chargebee Rails

[![Maintainability](https://api.codeclimate.com/v1/badges/2f9b7a79d17605b51f5e/maintainability)](https://codeclimate.com/github/spritlesoftware/chargebee-rails-subscriptions/maintainability)

This is the Rails gem for integrating with Chargebee. If you're new to Chargebee, sign up for an account [here](https://www.chargebee.com).

[Introduction](#introduction)

[Prerequisite](#prerequisite)

[Installation](#installation)

[Customer](#customer)

[Subscription](#subscription)

[Metered Billing](#metered-billing)










# Introduction

This ruby gem provides you with a set of boilerplate classes to accelerate the implementation of a subscription billing module onto your rails application. 

The gem can automatically handle:

   * Setting up of relevant db models to store subscription data.

   * Upgrade/downgrade of subscriptions.
   
   * Coupons.

   * Webhooks from Chargebee to ensure the data is in sync.


Apart from this, the gem also supports:

   * Template webhook handling controllers that you can simply inherit and override.

   * Pluggable tracking of metered billing usage (also customizable).

   * APIs to handle various subscription billing scenarios.


# Prerequisite

```ruby

    ruby > 2.0.0
    rails > 4.2.4

```

If the rest-client version is less than 1.8.0, update the latest version by running the command:

```ruby

    bundle update rest-client

```



# Installation

### Step 1: Install the “chargebee_rails” gem to your application

Add the below line to your Gemfile:


```ruby

    gem 'chargebee_rails'

```

And, run

```ruby

    bundle

```


### Step 2:  Add Subscription models to your app

The entity that uniquely identifies a customer account within your application is referred to as a subscription owner module. For example, if you are building a CRM application, the entity that represents the customer’s account will be your subscription owner entity.

The entity name has to be passed in _&lt;subscription_owner_entity&gt;_, so that the subscription models are setup with relation to this entity.

**Note**: *Presence of subscription owner model (For example user, customer, etc.) is required*



```ruby

    rails g chargebee_rails:install <subscription_owner_entity>

```

Allow migration to override templates


```ruby

    rake db:migrate

```



Now, you will have models and database tables set for subscriptions, plans, payment_methods and event_sync_logs.




### Step 3: Set up Chargebee


Configure your Chargebee site name and API key in the `config/initializers/chargebee_rails.rb` file. 

```ruby

    #The API key can be found in your Chargebee site under Settings> API & WEBHOOKS > API Keys

    config.chargebee_site = 'CHARGEBEE_SITE' 

    #The API key can be found in your Chargebee site under Settings> API & WEBHOOKS > API Keys
    
    config.chargebee_api_key = 'CHARGEBEE_API_KEY

```


## Gateway credentials

Payment Gateway credentials have to be set up in Chargebee under *Settings> Site Settings> Gateway Settings*.


## Webhook notifications

You can set up basic authentication for your incoming webhook notifications in `config/initializers/chargebee_rails.rb` file. 

```ruby

    config.secure_webhook_api = true
    
    config.webhook_authentication = {user: username, secret: password}

```



## Set the controller name used to handle webhooks

If you’d like to use a different controller to handle webhooks, you can extend the `ChargebeeRails::WebhookController` and add the controller name in config.webhook_handler.

```ruby

    #The username and password should match the ones specified in your Chargebee site settings under Settings> API & WEBHOOKS> Webhook Settings
    
    config.webhook_handler = 'webhook_overriding_controller_name'

```



For instance, if you have a controller *MyAppEventsController* in the `my_app_events_controller.rb` file, then set this as:

```ruby

    config.webhook_handler = 'my_app_events'

```

## Configure the webhook url in Chargebee

Configure the webhook url in Chargebee under *API & Webhooks> Webhook* Settings. The path can be specified as shown below:

```ruby

    config.webhook_api_path = 'chargebee_rails_event' 

```

*chargebee_rails_event* is the path you can use to receive events from Chargebee to your application. 

The webhook url for your site will be  _http(s)://&lt;your-domain&gt;.com/chargebee_rails_event_. 


## Sync plans

Currently Chargebee does not support webhook notifications for addition, update and removal of Plans. However, this gem comes with a rake task to sync plans between Chargebee and your application. Hence, each time a plan is created in Chargebee, it will automatically be synced with your application. In the future, we will have webhooks events in place to support plan related operations. Once that's done, the rake task’s code will be included as part of the event handler.

The plans can be synced to your application using the following command:

```ruby

    rake chargebee_rails:sync_plans

```


**Note**: The archived plans will also be synced in this method.


## Sync failed events

Chargebee attempts to send webhook notifications for upto 2 days. After 2 days, if the webhook event has failed due to some reason, the webhook’s status is marked as “Failed” and further attempts are stopped.  Once the error has been fixed at your end, the rake task will sync the failed events with your application. The failed events will be selectively sent to the webhook handler as well as hook methods, provided the event does not have an outdated update.


```ruby

    rake chargebee_rails:sync_failed_events

```



## Sync events with your application

The event types listed below are synced with the application by this gem

*  subscription_started
 
*  subscription_trial_end_reminder
 
*  subscription_activated
 
*  subscription_changed
 
*  subscription_cancellation_scheduled
 
*  subscription_cancellation_reminder
 
*  subscription_cancelled
 
*  subscription_reactivated
 
*  subscription_renewed
 
*  subscription_scheduled_cancellation_removed
 
*  subscription_renewal_reminder
 
*  card_expired
 
*  card_updated
 
*  card_expiry_reminder



## Configure your default plan Id#

When a customer signs up for a trial account, you will associate the subscription with a particular plan in Chargebee. This plan can be configured as the default plan in the gem, so that the the plan name is automatically passed during subscription creation.
This way, when calling the [create a subscription](https://apidocs.chargebee.com/docs/api/subscriptions#create_a_subscription) API, if the plan id is not passed in the subscription method,  it will be taken from `config.default_plan_id`.

```ruby

    config.default_plan_id = 'your_default_plan_id'

```




## Advanced settings

If you would like to control the subscription upgrade/downgrade behaviour, you can specify this in:

```ruby

    config/initializers/chargebee_rails.rb

```

The subscription's default [term end](https://apidocs.chargebee.com/docs/api/subscriptions#change_term_end) (the date when the subscription's term gets over) value can also be specified for subscription related changes like subscription update and cancellation.

```ruby

    config.end_of_term = false

```

If the above parameter is set to true, subscription changes will be made at the end of term or during next renewal. 

 ```ruby
 
    config.proration = true

```

If the above parameter is set to true, prorated charges will be applied during subscription change.

If you’d like to include delayed charges during [update_subscription_estimate](https://apidocs.chargebee.com/docs/api/estimates#update_subscription_estimate), you can specify the *include_delayed_charges* parameter in `config/initializers/chargebee_rails.rb`.

 ```ruby
 
    config.include_delayed_charges = { 
      changes_estimate: false, 
      renewal_estimate: true 
    }

 ```

## Customer

**Retrieve as Chargebee Customer**

 ```ruby
    
    customer = Customer.first
    
    customer.as_chargebee_customer

 ```

**Update a Customer**

 ```ruby
 
    ChargebeeRails.update_customer(customer, {})

``` 
    
**Update billing info for a Customer**

```ruby
  
    ChargebeeRails.update_billing_addr(customer, {})
  
```
  
**Update contacts for a customer**

```ruby

    ChargebeeRails.add_customer_contacts(customer, {})

 ```


## Subscription

**Create a Subscription**

 ```ruby
 
    customer = Customer.find(1)
    
    customer.subscribe(customer: customer_params)

 ```
 
 **Update a Subscription**
 
 ```ruby
 
    customer.update_subscription(plan_id: params[:plan_id], coupon: params[:coupon_id])
 
 ```
 
 **Retrieve a Subscription**
 
  ```ruby
 
    subscription = customer.subscription
  
    subscription.as_chargebee_subscription
    
   ```
 
 **Update Plan for a Subscription**
 
```ruby
 
    subscription.change_plan(plan_object, end_of_term=false)   # end_of_term is optional
 
 ```
 
**Update Plan quantity for a Subscription**
 
 ```ruby
 
    subscription.set_plan_quantity(quantity, end_of_term=false)  # end_of_term is optional
 
 ```
 
 **Add Or remove Addons for a Subscription**
  
 ```ruby
 
    subscription.manage_addons(addon_id, quantity=1)

 ```
 
 **Cancel a Subscription**
 
 ```ruby
 
    subscription.cancel(params)

 ```
 
 **Remove scheduled cancellation for a Subscription**

 ``` ruby
 
    subscription.stop_cancellation
 
  ```


# Metered billing

If you’d like to charge your customers based on usage, you could enable the Metered Billing option. This option can be enabled by checking the *Notify and wait to close invoices* option under *Settings> Site Settings> Site* Info. 

**Note:** The above mentioned webhook configuration is mandatory for Metered Billing.

The subscription’s usage charges have to tracked from your end. During renewal, a pending invoice will be created and this will be sent to you through a webhook. You would have to implement the *ChargebeeRails::MeteredBilling.close_invoice(invoice_id)* method where you will get the invoice object. Using the invoice object, you can add the subscription and its charges.
Use the below API method to add the line items to the pending invoice after you have calculated how much the customer needs to be charged

**Add charge to pending Invoice**

``` ruby

    ChargebeeRails::MeteredBilling.add_charge(invoice_id, amount, description)

```


**Add Addon charge to pending Invoice**

``` ruby

    ChargebeeRails::MeteredBilling.add_addon_charge(invoice_id, addon_id, addon_quantity)

```


**Close Invoice**

``` ruby

    ChargebeeRails::MeteredBilling.close_invoice(invoice_id)

```



## Support and contribution

If you’d like us to guide you through the set up process or if you have any questions regarding the Ruby gem implementation, contact us at chargebee@spritle.com. For feature requests or feedback, submit [here](https://github.com/spritlesoftware/chargebee-rails-subscriptions/issues/new).

If you have questions regarding how Chargebee works, send an email to support@chargebee.com. 

## Pull requests

If you’ve added new functionalities that you think might be helpful for all, do send us a pull request.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

