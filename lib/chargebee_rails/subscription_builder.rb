module ChargebeeRails
  class SubscriptionBuilder

    def initialize(customer, options)
      @customer = customer
      @options = options
    end

    # Create a subscription in Chargebee,
    # update the resulting subscription details for the customer in the 
    # application and finally return the subscription
    def create
      build_subscription_payload
      create_subscriptions
      manage_payment_method if chargebee_payment_method.present?
      @subscription
    end

    # Update existing subscription in Chargebee,
    # the resulting subscription details are then updated in application
    def update
      update_subscriptions
      manage_payment_method if chargebee_payment_method.present?
      @subscription
    end

    private

    # Create a subscription in Chargebee with the passed options payload
    def create_subscriptions
      @result = ChargeBee::Subscription.create(@options)
      @customer.update(
        chargebee_id: chargebee_customer.id,
        chargebee_data: chargebee_customer_data
      ) # Update the chargebee customer id for the subscription owner
      @subscription = @customer.create_subscription(subscription_attrs) # Create an active record subscription of the chargebee subscription object for the customer
    end

    # Update subscription in ChargeBee and the application model
    def update_subscriptions
      @subscription = @customer.subscription
      @options[:prorate] ||= ChargebeeRails.configuration.proration
      @result = ChargeBee::Subscription.update(@subscription.chargebee_id, @options)
      @plan = Plan.find_by(plan_id: @result.subscription.plan_id)
      @subscription.update(subscription_attrs)
    end

    # Update payment method for subscrption if one exists or create new one
    def manage_payment_method
      @subscription.payment_method.present? &&
      @subscription.payment_method.update(payment_method_attrs) ||
      create_payment_method
    end

    # Create the payment method for the subscription
    def create_payment_method
      @subscription.create_payment_method(payment_method_attrs)
    end

    # Check for the default plan if one is not passed in the options payload
    # raise plan not configured error incase plan is not passed and a default
    # plan is not set in the ChargebeeRails configuration. 
    # Raise plan not found if the plan passed is not found in active record
    def build_subscription_payload
      @options[:trial_end] = 0 if @options[:skip_trial]
      @options[:plan_id] ||= ChargebeeRails.configuration.default_plan_id
      raise PlanError.new.plan_not_configureed unless @options[:plan_id]
      @plan = Plan.find_by(plan_id: @options[:plan_id])
      raise PlanError.new.plan_not_found unless @plan
    end

    def chargebee_subscription
      @chargebee_subscription ||= @result.subscription
    end

    def chargebee_customer
      @chargebee_customer ||= @result.customer
    end

    def chargebee_payment_method
      @chargebee_payment_method ||= chargebee_customer.payment_method
    end

    def chargebee_card
      @chargebee_card ||= @result.card
    end

    def chargebee_billing_address
      @chargebee_billing_address ||= chargebee_customer.billing_address
    end

    def subscription_attrs
      {
        chargebee_id: chargebee_subscription.id,
        status: chargebee_subscription.status,
        plan_quantity: chargebee_subscription.plan_quantity,
        chargebee_data: chargebee_subscription_data,
        plan: @plan
      }
    end

    def chargebee_subscription_data
      {
        trial_ends_at: chargebee_subscription.trial_end,
        next_renewal_at: chargebee_subscription.current_term_end,
        cancelled_at: chargebee_subscription.cancelled_at,
        is_scheduled_for_cancel: (chargebee_subscription.status == 'non-renewing' ? true : false),
        has_scheduled_changes: chargebee_subscription.has_scheduled_changes
      }
    end

    def chargebee_customer_data
      {
        customer_details: customer_details(chargebee_customer),
        billing_address: billing_address(chargebee_customer.billing_address)
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

    def payment_method_attrs
      if chargebee_payment_method.type == 'card'
        card_last4, card_type = chargebee_card.last4, chargebee_card.card_type
      else
        card_last4, card_type = nil, nil
      end
      {
        cb_customer_id: chargebee_customer.id,
        auto_collection: chargebee_customer.auto_collection,
        payment_type: chargebee_payment_method.type,
        reference_id: chargebee_payment_method.reference_id,
        card_last4: card_last4,
        card_type: card_type,
        status: chargebee_payment_method.status
      }
    end

  end
end
