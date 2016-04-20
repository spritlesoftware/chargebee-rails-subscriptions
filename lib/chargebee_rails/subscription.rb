module ChargebeeRails
  module Subscription

    def self.included(base)
      base.extend(ClassMethods)
    end

    # Get the Chargebee equivalent subscription for the corresponding
    # active record subscription
    def as_chargebee_subscription
      ChargeBee::Subscription.retrieve(chargebee_id).subscription
    end

    # Update plan for a subscription
    def change_plan(plan, end_of_term=nil, proration=nil)
      end_of_term ||= ChargebeeRails.configuration.end_of_term
      proration ||= ChargebeeRails.configuration.proration
      subscription = ChargeBee::Subscription.update(
        chargebee_id, {plan_id: plan.plan_id, end_of_term: end_of_term, prorate: proration}
      ).subscription
      update(subscription_attributes(subscription, plan))
    end

    # Update plan quantity for subscription
    def set_plan_quantity(quantity, end_of_term=false)
      subscription = ChargeBee::Subscription.update(
        chargebee_id, { plan_quantity: quantity, end_of_term: end_of_term }
      ).subscription
      update(subscription_attributes(subscription, plan))
    end

    # Cancel a subscription - it will be scheduled for cancellation at term end
    # when end_of_term is passed as true. If no options are passed the 
    # default configured value for end_of_term is taken
    def cancel(options={})
      options[:end_of_term] ||= ChargebeeRails.configuration.end_of_term
      subscription = ChargeBee::Subscription.cancel(chargebee_id, options).subscription
      update(
        status: subscription.status
      )
    end

    # Stop a scheduled cancellation of a subscription
    def stop_cancellation
      ChargeBee::Subscription.remove_scheduled_cancellation(chargebee_id).subscription
    end

    # Reactivate a cancelled subscription
    def reactivate
      subscription = ChargeBee::Subscription.reactivate(chargebee_id).subscription
      update(
        status: subscription.status
      )
    end

    # Estimates the subscription's renewal  
    def estimate_renewal(options={})
      options[:include_delayed_charges] ||= ChargebeeRails.configuration.include_delayed_charges[:renewal_estimate]
      ChargeBee::Estimate.renewal_estimate(chargebee_id, options).estimate
    end

    module ClassMethods
      
      # Estimates the cost of subscribing to a new subscription
      def estimate(estimation_params)
        ::ChargeBee::Estimate.create_subscription(estimation_params).estimate
      end

      # Estimates the cost of changes to an existing subscription
      # estimates the upgrade/downgrade or other changes
      def estimate_changes(estimation_params)
        estimation_params[:include_delayed_charges] ||= ChargebeeRails.configuration.include_delayed_charges[:changes_estimate]
        ::ChargeBee::Estimate.update_subscription(estimation_params).estimate
      end

    end

    private

    def subscription_attributes(subscription, plan)
      params = { chargebee_plan: subscription.plan_id, plan_id: plan.id, status: subscription.status,
        has_scheduled_changes: subscription.has_scheduled_changes }
    end

  end
end
