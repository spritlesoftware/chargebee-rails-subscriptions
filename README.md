# ChargebeeRails

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/chargebee_rails`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

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
  rake chargebee_rails:sync_plan
```


Configure the app for setting a default plan for you application

```ruby
# config/initializers/chargebee_rails.rb
    
ChargebeeRails.configure do |config|
    config.default_plan_id = '<your_plan_in_chargebee>'
end
```

## Signup

Creates a new subscription along with the customer.

```ruby
    customer = Customer.find(id)
    customer.subscribe(customer: customer_params)
```
## Customer

#####Retrieve a customer

 ```ruby   
 customer.as_chargebee_customer
```


##  Hosted pages

Checkout new subscription

```ruby
hosted_page = ChargeBee::HostedPage.retrieve(params[:hosted_page_id]).hosted_page
customer.subscribe_via_hosted_page(hosted_page)
```

Checkout existing subscription

```ruby
hosted_page = ChargeBee::HostedPage.retrieve(params[:hosted_page_id]).hosted_page
customer.update_subscription_via_hosted_page(hosted_page)
```

## Subscription

Update Subscriber

```ruby
ChargebeeRails.update_subscriber(subscriber, {})
```

Update Billing Address

```ruby
ChargebeeRails.update_billing_addr(subscriber, {})
```

Add Subscriber Contacts

```ruby
ChargebeeRails.add_subscriber_contacts(subscriber, {})
```

Update a subscription
```ruby
customer.update_subscription(plan_id: params[:plan_id], coupon: params[:coupon_id])
```

Retrieve a subscription
```ruby
subscription.as_chargebee_subscription
```
      
Update plan for a subscription
```ruby
subscription.change_plan(plan_object, end_of_term=false)   # end_of_term is optional
```
Update plan quantity for subscription
```ruby
subscription.set_plan_quantity(quantity, end_of_term=false)  # end_of_term is optional
```

Add or remove addons for the subscription
```ruby
subscription.manage_addons(addon_id, quantity=1)
```

Cancel a subscription
```ruby
subscription.cancel(params)
```

Remove scheduled cancellation
```ruby
subscription.stop_cancellation
```

## Invoices

  List invoices

```ruby
customer.invoices
```
## Metered Billing
Metered billing, or usage based subscriptions typically works with a plan that includes a base fee and a usage fee.

**Note**: You need to enable metered billing manually in chargebee web interface**


**Add Charge to Pending Invoice**


To add the line items to the invoice after you have calculated how much the customer needs to be charged.

```ruby
ChargebeeRails::MeteredBilling.add_charge(invoice_id, amount, description)
```
invoice_id : Unique id of the invoice

amount : The amount to be charged required, in cents, min=1

description : Detailed description about this lineitem.

**Add addon charge to pending invoice**
 

```ruby
ChargebeeRails::MeteredBilling.add_addon_charge(invoice_id, addon_id, addon_quantity)
```

**Close invoice**

```ruby
ChargebeeRails::MeteredBilling.close_invoice(invoice_id)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, 

```ruby
run `bundle exec rake install`
```
To release a new version, update the version number in `version.rb`, and then run 
```ruby
bundle exec rake release
```
which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/chargebee_rails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

