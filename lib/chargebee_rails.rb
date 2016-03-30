require "chargebee_rails/version"
require "chargebee_rails/configuration"
require "chargebee_rails/errors"
require "generators/chargebee_rails/install_generator"
require "chargebee_rails/chargeable_subscription"
require "chargebee_rails/subscription_builder"
require "chargebee_rails/subscriber"

module ChargebeeRails
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

  def self.update_billing_addr(subscriber, options={})
    ChargeBee::Customer.update_billing_info(subscriber.chargebee_id, options).customer
  end

  def self.add_subscriber_contacts(subscriber, options={})
    ChargeBee::Customer.add_contact(subscriber.chargebee_id, options).customer
  end

  def self.update_subscriber_contacts(subscriber, options={})
    ChargeBee::Customer.update_contact(subscriber.chargebee_id, options).customer
  end

  def self.retrieve_subscriber(subscriber)
    ChargeBee::Customer.retrieve(subscriber.chargebee_id).customer
  end
end
