module ChargebeeRails
  class SubscriptionBuilder
    def initialize(customer, plan, options)
      @customer = customer
      @plan = plan
      @options = options
    end

    def create
      @result = create_cb_subscription
      @customer.update(chargebee_id: @result.customer.id)
      create_local_subscription
      update_card
      @subscription
    end

    private

    def create_cb_subscription
      ChargeBee::Subscription.create(subscription_payload)
    end

    def create_local_subscription
      @chargebee_subscription = @result.subscription
      @subscription = @customer.create_subscription({
        chargebee_id: @chargebee_subscription.id,
        chargebee_plan: @chargebee_subscription.plan_id,
        status: @chargebee_subscription.status,
        plan: @plan
      })
    end

    def update_card
      @chargebee_card = @result.card
      if @chargebee_card.present?
        @subscription.create_card(
          cb_customer_id: @chargebee_card.customer_id,
          last4: @chargebee_card.last4,
          card_type: @chargebee_card.card_type,
          status: @chargebee_card.status
        )
      end
    end

    def subscription_payload
      {
        plan_id: @plan.plan_id
      }.deep_merge(@options)
    end
  end
end
