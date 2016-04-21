module ChargebeeRails
  class HostedPageSubscriptionManager

    def initialize(customer, hosted_page)
      @customer = customer
      @hosted_page = hosted_page
    end

    def create
      @subscription = @customer.create_subscription(subscription_attrs)
      create_card_for_subscription
      @subscription
    end

    def update
      @subscription = @customer.subscription
      @subscription.update(subscription_attrs)
      create_card_for_subscription
      @subscription
    end

    private

    def subscription_attrs
      {
        chargebee_id: hosted_subscription.id,
        chargebee_plan: hosted_subscription.plan_id,
        status: hosted_subscription.status,
        has_scheduled_changes: hosted_subscription.has_scheduled_changes,
        plan: Plan.find_by(plan_id: hosted_subscription.plan_id)
      }
    end

    def create_card_for_subscription
      @subscription.create_card(
        cb_customer_id: hosted_card.customer_id,
        last4: hosted_card.last4,
        card_type: hosted_card.card_type,
        status: hosted_card.status
      )
    end

    def hosted_subscription
      @hosted_subscription ||= @hosted_page.content.subscription
    end

    def hosted_card
      @hosted_card ||= @hosted_page.content.card
    end

  end
end
