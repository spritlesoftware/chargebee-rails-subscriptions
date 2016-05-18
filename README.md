# Chargebee Rails
This is the Rails gem for integrating with Chargebee. Sign up for a Chargebee account [here](https://www.chargebee.com).

## Installation

Add this line to your Gemfile:

```ruby
gem 'chargebee_rails'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chargebee_rails

## Usage

Add subscription models to your app

    $ rails g chargebee_rails:install <subscription_owner_model>

(Note: Allow migration to override templates)

Migrate the changes

    $ rake db:migrate

Add your CHARGEBEE_SITE and CHARGEBEE_API_KEY values in config/intializers/chargebee_rails.rb


**Sync Plans**

If you have setup plans in chargebee, run this task to sync the plans

```ruby
 $ rake chargebee_rails:sync_plan
```


Configure the app for setting a default plan for you application

```ruby
# config/initializers/chargebee_rails.rb
    
ChargebeeRails.configure do |config|
  config.default_plan_id = '<your_plan_in_chargebee>'
end
```

## Customer

Creates a new subscription for the customer.

```ruby
<customer_object>.subscribe(customer: customer_params)
```

Retrieve a customer

```ruby   
<customer_object>.as_chargebee_customer
```

Update a customer

```ruby
ChargebeeRails.update_subscriber(<customer_object>, {})
```

Update billing info for a customer

```ruby
ChargebeeRails.update_billing_addr(<customer_object>, {})
```

Update Contacts for a customer

```ruby
ChargebeeRails.add_subscriber_contacts(<customer_object>, {})
```

## Hosted pages

Checkout new subscription

```ruby
hosted_page = ChargeBee::HostedPage.retrieve(params[:hosted_page_id]).hosted_page
<customer_object>.subscribe_via_hosted_page(hosted_page)
```

Checkout existing subscription

```ruby
hosted_page = ChargeBee::HostedPage.retrieve(params[:hosted_page_id]).hosted_page
<customer_object>.update_subscription_via_hosted_page(hosted_page)
```

## Subscription


Update a subscription
```ruby
<customer_object>.update_subscription(plan_id: params[:plan_id], coupon: params[:coupon_id])
```

Retrieve a subscription
```ruby
<subscription_object>.as_chargebee_subscription
```

Update plan for a subscription
```ruby
<subscription_object>.change_plan(plan_object, end_of_term=false)   # end_of_term is optional
```
Update plan quantity for subscription
```ruby
<subscription_object>.set_plan_quantity(quantity, end_of_term=false)  # end_of_term is optional
```

Add or remove addons for the subscription
```ruby
<subscription_object>.manage_addons(addon_id, quantity=1)
```

Cancel a subscription
```ruby
<subscription_object>.cancel(params)
```

Remove scheduled cancellation
```ruby
<subscription_object>.stop_cancellation
```
Reactivate a subscription
```ruby
<subscription_object>.reactivate
```
## Estimates

Create subscription estimate
```ruby
estimation_params = {
  subscription: {
    plan_id: "basic"
  }, 
  billing_address: {
    line1: "PO Box 9999", 
    city: "Walnut", 
    zip: "91789", 
    country: "US"
  }
}
Subscription.estimate(estimation_params)
```
Subscription renewal estimate
```ruby
estimation_params = { include_delayed_charges: '', use_existing_balances: '' }
<subscription_object>.estimate(estimation_params)
```

Update subscription estimate
```ruby
estimation_params = {
subscription: {
    id: "5cDfREwp3I5lJ", 
    plan_id: "basic"
  }, 
  billing_address: {
    line1: "PO Box 9999", 
    city: "Walnut", 
    zip: "91789", 
    country: "US"
  }
}
Subscription.estimate_changes(estimation_params)
```

## Invoices

List invoices

```ruby
<customer_object>.invoices
```
## Metered Billing
Metered billing, or usage based subscriptions typically works with a plan that includes a base fee and a usage fee.

**Note**: You need to enable metered billing manually in chargebee web interface


Add Charge to Pending Invoice


To add the line items to the invoice after you have calculated how much the customer needs to be charged.

```ruby
ChargebeeRails::MeteredBilling.add_charge(invoice_id, amount, description)
```

Add addon charge to pending invoice
 

```ruby
ChargebeeRails::MeteredBilling.add_addon_charge(invoice_id, addon_id, addon_quantity)
```

Close invoice

```ruby
ChargebeeRails::MeteredBilling.close_invoice(invoice_id)
```


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

