require "chargebee_rails/version"
require "generators/chargebee_rails/install_generator"
require "chargebee_rails/chargeable_subscription"
require "chargebee_rails/subscription_builder"

module ChargebeeRails
  def subscribe(plan, options={})
    SubscriptionBuilder.new(self, plan, options).create
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
end
