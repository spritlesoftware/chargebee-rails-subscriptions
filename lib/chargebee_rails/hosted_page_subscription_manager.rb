module ChargebeeRails
  class HostedPageSubscriptionManager

    def initialize(customer, hosted_page)
      @customer = customer
      @hosted_page = hosted_page
    end

    # Create a subscription for the customer in application,
    # from the subscription details got from chargebee's hosted page
    def create
      @customer.update(
        chargebee_id: hosted_customer.id,
        chargebee_data: chargebee_customer_data
      )
      @subscription = @customer.create_subscription(subscription_attrs)
      manage_payment_method if hosted_payment_method.present?
      @subscription
    end

    # Update the subscription for the customer in application,
    # from the subscription details got from chargebee's hosted page
    def update
      @subscription = @customer.subscription

      #if we're just updating the payment method, then the subscription can be empty
      @subscription.update(subscription_attrs) if hosted_subscription.present?

      manage_payment_method if hosted_payment_method.present?
      @subscription
    end

    private

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

    def hosted_subscription
      @hosted_subscription ||= @hosted_page.content.subscription
    end

    def hosted_customer
      @hosted_customer ||= @hosted_page.content.customer
    end

    def hosted_payment_method
      @hosted_payment_method ||= hosted_customer.payment_method
    end

    def hosted_card
      @hosted_card ||= @hosted_page.content.card
    end

    def hosted_billing_address
      @hosted_billing_address ||= @hosted_customer.billing_address
    end

    def subscription_attrs
      {
        chargebee_id: hosted_subscription.id,
        status: hosted_subscription.status,
        plan_quantity: hosted_subscription.plan_quantity,
        chargebee_data: chargebee_subscription_data,
        plan: Plan.find_by(plan_id: hosted_subscription.plan_id)
      }
    end

    def chargebee_subscription_data
      {
        trial_ends_at: hosted_subscription.trial_end,
        next_renewal_at: hosted_subscription.current_term_end,
        cancelled_at: hosted_subscription.cancelled_at,
        is_scheduled_for_cancel: (hosted_subscription.status == 'non-renewing' ? true : false),
        has_scheduled_changes: hosted_subscription.has_scheduled_changes
      }
    end

    def chargebee_customer_data
      {
        customer_details: customer_details(hosted_customer),
        billing_address: billing_address(hosted_customer.billing_address)
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
      if hosted_payment_method.type == 'card'
        card_last4, card_type = hosted_card.last4, hosted_card.card_type
      else
        card_last4, card_type = nil, nil
      end
      {
        cb_customer_id: hosted_customer.id,
        auto_collection: (hosted_customer.auto_collection == 'on' ? true : false),
        payment_type: hosted_payment_method.type,
        reference_id: hosted_payment_method.reference_id,
        card_last4: card_last4,
        card_type: card_type,
        status: hosted_payment_method.status
      }
    end

  end
end
