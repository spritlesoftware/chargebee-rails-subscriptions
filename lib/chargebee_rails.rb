require "chargebee_rails/version"
require "chargebee"
require "rails"
require "chargebee_rails/engine"
require "chargebee_rails/event_handler"
require "chargebee_rails/configuration"
require "chargebee_rails/errors"
require "generators/chargebee_rails/install_generator"
require "chargebee_rails/subscription"
require "chargebee_rails/subscription_builder"
require "chargebee_rails/hosted_page_subscription_manager"
require "chargebee_rails/subscriber"
require "chargebee_rails/card"
require "chargebee_rails/metered_billing"

module ChargebeeRails

  # Update the chargebee customer details by passing the subscription owner object
  # and the details hash as the options
  def self.update_subscriber(subscriber, options={})
    result = ChargeBee::Customer.update(subscriber.chargebee_id, options)
    customer = result.customer
    subscriber.update(
      first_name: customer.first_name,
      last_name: customer.last_name,
      email: customer.email,
      phone: customer.phone
    )
  end

  # Updating the billing address of the subscription owner. The subscription
  # owner object and the billing address details as options must be provided
  def self.update_billing_addr(subscriber, options={})
    ChargeBee::Customer.update_billing_info(subscriber.chargebee_id, options).customer
  end

  # Adding contacts to a chargebee customer - subscriber is the subscription owner 
  # object and the contact details hash is given as options
  def self.add_subscriber_contacts(subscriber, options={})
    ChargeBee::Customer.add_contact(subscriber.chargebee_id, options).customer
  end

  # Updating the contacts for a chargebee customer - the chargebee contact id
  # must be passed in the options to update the existing contact for the
  # subscription owner 
  def self.update_subscriber_contacts(subscriber, options={})
    ChargeBee::Customer.update_contact(subscriber.chargebee_id, options).customer
  end
end
