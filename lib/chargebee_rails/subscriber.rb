module ChargebeeRails
  module Subscriber

    # Subscribe customer to a new subscription
    def subscribe(options={})
      SubscriptionBuilder.new(self, options).create
    end

    # Subscribe customer to a new subscription via hosted page
    def subscribe_via_hosted_page(hosted_page)
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

    # Retrieve subscriber as chargebee customer
    def as_chargebee_customer
      ChargeBee::Customer.retrieve(chargebee_id).customer
    end

    # List all invoices for the customer
    def invoices
      ChargeBee::Invoice.invoices_for_customer(chargebee_id).map(&:invoice)
    end

  end
end
