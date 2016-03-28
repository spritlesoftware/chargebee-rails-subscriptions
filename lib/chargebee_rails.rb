require "chargebee_rails/version"
require "chargebee_rails/configuration"
require "generators/chargebee_rails/install_generator"
require "chargebee_rails/chargeable_subscription"
require "chargebee_rails/subscription_builder"

module ChargebeeRails
  def subscribe(options={})
    SubscriptionBuilder.new(self, options).create
  end

  def create_subscription_from_hosted_page(hosted_page)
    hosted_subscription = hosted_page.content.subscription
    hosted_card = hosted_page.content.card
    subscription = self.create_subscription(
      chargebee_id: hosted_subscription.id,
      chargebee_plan: hosted_subscription.plan_id,
      status: hosted_subscription.status,
      plan: Plan.find_by(plan_id: hosted_subscription.plan_id)
    )
    subscription.create_card(
      cb_customer_id: hosted_card.customer_id,
      last4: hosted_card.last4,
      card_type: hosted_card.card_type,
      status: hosted_card.status
    )
    subscription
  end

  def update_owner_details(options={})
    result = ChargeBee::Customer.update(chargebee_id, options)
    customer = result.customer
    update(
      first_name: customer.first_name,
      last_name: customer.last_name,
      email: customer.email,
      phone: customer.phone
    )
  end

  def update_billing_details(options={})
    ChargeBee::Customer.update_billing_info(chargebee_id, options).customer
  end

  def add_contacts(options={})
    ChargeBee::Customer.add_contact(chargebee_id, options).customer
  end

  def update_contacts(options={})
    ChargeBee::Customer.update_contact(chargebee_id, options).customer
  end
end
