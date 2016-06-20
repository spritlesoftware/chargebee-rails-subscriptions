require "chargebee_rails/version"
require "chargebee"
require "rails"
require "chargebee_rails/engine"
require "chargebee_rails/webhook_handler"
require "chargebee_rails/configuration"
require "chargebee_rails/errors"
require "generators/chargebee_rails/install_generator"
require "chargebee_rails/subscription"
require "chargebee_rails/subscription_builder"
require "chargebee_rails/hosted_page_subscription_manager"
require "chargebee_rails/customer"
require "chargebee_rails/metered_billing"

module ChargebeeRails
  # Update the chargebee customer details by passing the subscription owner object
  # and the details hash as the options
  def self.update_customer(customer, options={})
    chargebee_customer = ChargeBee::Customer.update(customer.chargebee_id, options).customer
    customer.update(chargebee_id: chargebee_customer.id, chargebee_data: chargebee_customer_data(chargebee_customer))
    customer
  end

  # Updating the billing address of the subscription owner. The subscription
  # owner object and the billing address details as options must be provided
  def self.update_billing_addr(customer, options={})
    chargebee_customer = ChargeBee::Customer.update_billing_info(customer.chargebee_id, options).customer
    customer.update(chargebee_id: chargebee_customer.id, chargebee_data: chargebee_customer_data(chargebee_customer))
    customer
  end

  # Adding contacts to a chargebee customer - subscriber is the subscription owner 
  # object and the contact details hash is given as options
  def self.add_customer_contacts(customer, options={})
    ChargeBee::Customer.add_contact(customer.chargebee_id, options).customer
  end

  # Updating the contacts for a chargebee customer - the chargebee contact id
  # must be passed in the options to update the existing contact for the
  # subscription owner 
  def self.update_customer_contacts(customer, options={})
    ChargeBee::Customer.update_contact(customer.chargebee_id, options).customer
  end

  def chargebee_customer_data customer
    {
      customer_details: customer_details(customer),
      billing_address: billing_address(customer.billing_address)
    }
  end

  def customer_details customer
    {
      first_name: customer.first_name,
      last_name: customer.last_name,
      email: customer.email,
      company: customer.company,
      vat_number: customer.vat_number
    }
  end

  def billing_address customer_billing_address
    {
      first_name: customer_billing_address.first_name,
      last_name: customer_billing_address.last_name,
      company: customer_billing_address.company,
      address_line1: customer_billing_address.line1,
      address_line2: customer_billing_address.line2,
      address_line3: customer_billing_address.line3,
      city: customer_billing_address.city,
      state: customer_billing_address.state,
      country: customer_billing_address.country,
      zip: customer_billing_address.zip
    } if customer_billing_address.present?
  end
end
