module ChargebeeRails
  class SubscriptionBuilder

    def initialize(customer, options)
      @customer = customer
      @options = options
    end

    # Here we will create a subscription in Chargebee,
    # update the resulting subscription details for the customer in the 
    # active record database and finally return the 
    # active record subscription object
    def create
      @result = create_chargebee_subscription
      @customer.update(chargebee_id: @result.customer.id)
      create_local_subscription
      update_card
      @subscription
    end

    private

    # Create a subscription in Chargebee with the passed options payload
    def create_chargebee_subscription
      ChargeBee::Subscription.create(subscription_payload)
    end

    # Create an active record subscription of the chargebee subscription object 
    # for the customer
    def create_local_subscription
      @chargebee_subscription = @result.subscription
      @subscription = @customer.create_subscription({
        chargebee_id: @chargebee_subscription.id,
        chargebee_plan: @chargebee_subscription.plan_id,
        status: @chargebee_subscription.status,
        plan: @plan
      })
    end

    # Update the card details of the user if one is passed during subscription
    def update_card
      @chargebee_card = @result.card
      @subscription.create_card(
        cb_customer_id: @chargebee_card.customer_id,
        last4: @chargebee_card.last4,
        card_type: @chargebee_card.card_type,
        status: @chargebee_card.status
      ) if @chargebee_card.present?
    end

    # Check for the default plan if one is not passed in the options payload
    # raise plan not configured error incase plan is not passed and a default
    # plan is not set in the ChargebeeRails configuration. 
    # Raise plan not found if the plan passed is not found in active record  
    def subscription_payload
      @options[:plan_id] ||= ChargebeeRails.configuration.default_plan_id
      raise PlanError.new.plan_not_configureed unless @options[:plan_id]
      @plan = Plan.find_by(plan_id: @options[:plan_id])
      raise PlanError.new.plan_not_found unless @plan
    end
  end
end
