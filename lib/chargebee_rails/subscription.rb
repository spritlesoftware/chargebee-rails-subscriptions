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
    def change_plan(plan, end_of_term=nil, prorate=nil)
      end_of_term ||= ChargebeeRails.configuration.end_of_term
      prorate ||= ChargebeeRails.configuration.proration
      chargebee_subscription = ChargeBee::Subscription.update(
        chargebee_id, { plan_id: plan.plan_id, end_of_term: end_of_term, prorate: prorate }
      ).subscription
      update(subscription_attrs(chargebee_subscription, plan))
    end

    # Update plan quantity for subscription
    def set_plan_quantity(quantity, end_of_term=nil, prorate=nil)
      end_of_term ||= ChargebeeRails.configuration.end_of_term
      prorate ||= ChargebeeRails.configuration.proration
      chargebee_subscription = ChargeBee::Subscription.update(
        chargebee_id, { plan_quantity: quantity, end_of_term: end_of_term, prorate: prorate }
      ).subscription
      update(subscription_attrs(chargebee_subscription, self.plan))
    end

    # Add or remove addons for the subscription
    def manage_addons(addon_id, quantity=1, replace_addon_list=false)
      chargebee_subscription = ChargeBee::Subscription.update(
        chargebee_id, { replace_addon_list: replace_addon_list, addons: [{ id: addon_id, quantity: quantity }] }
      ).subscription
    end

    # Cancel a subscription - it will be scheduled for cancellation at term end
    # when end_of_term is passed as true. If no options are passed the 
    # default configured value for end_of_term is taken
    def cancel(options={})
      options[:end_of_term] ||= ChargebeeRails.configuration.end_of_term
      chargebee_subscription = ChargeBee::Subscription.cancel(chargebee_id, options).subscription
      update(status: chargebee_subscription.status)
    end

    # Stop a scheduled cancellation of a subscription
    def stop_cancellation
      chargebee_subscription = ChargeBee::Subscription.remove_scheduled_cancellation(chargebee_id).subscription
      update(status: chargebee_subscription.status)
    end

    # Estimates the subscription's renewal  
    def estimate_renewal(options={})
      options[:include_delayed_charges] ||= ChargebeeRails.configuration.include_delayed_charges[:renewal_estimate]
      ChargeBee::Estimate.renewal_estimate(chargebee_id, options).estimate
    end

    module ClassMethods
      
      # Estimates the cost of subscribing to a new subscription
      def estimate(estimation_params)
        estimation_params[:trial_end] ||= 0
        ::ChargeBee::Estimate.create_subscription(estimation_params).estimate
      end

      # Estimates the cost of changes to an existing subscription
      # estimates the upgrade/downgrade or other changes
      def estimate_changes(estimation_params)
        estimation_params[:include_delayed_charges] ||= ChargebeeRails.configuration.include_delayed_charges[:changes_estimate]
        estimation_params[:prorate] ||= ChargebeeRails.configuration.proration
        ::ChargeBee::Estimate.update_subscription(estimation_params).estimate
      end

    end

    private

    def subscription_attrs(subscription, plan)
      {
        chargebee_id: subscription.id,
        plan_id: plan.id,
        plan_quantity: subscription.plan_quantity,
        status: subscription.status,
        chargebee_data: chargebee_subscription_data(subscription)
      }
    end

    def chargebee_subscription_data subscription
      {
        trial_ends_at: subscription.trial_end,
        next_renewal_at: subscription.current_term_end,
        cancelled_at: subscription.cancelled_at,
        is_scheduled_for_cancel: (subscription.status == 'non-renewing' ? true : false),
        has_scheduled_changes: subscription.has_scheduled_changes
      }
    end

  end
end
