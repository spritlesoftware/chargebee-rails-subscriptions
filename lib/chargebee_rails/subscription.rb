module ChargebeeRails
  module Subscription

    # Extend the class methods of including class
    def self.included(base) #:nodoc:
      base.extend(ClassMethods)
    end

    # Retrieve subscription as chargebee subscription
    def as_chargebee_subscription
      ChargeBee::Subscription.retrieve(chargebee_id).subscription
    end

    #
    # Update the plan for a subscription
    # * *Args*    :
    #   - +plan+ -> the plan to be updated
    #   - +end_of_term+ -> this boolean option specifies if the update takes 
    #     effect after term end, the default behavior will be as per configuration
    #   - +prorate+ -> this boolean option specifies if the updates to subscription
    #     are prorated, the default behavior will be as per configuration
    # For more details on the *updating plan for subscription*, refer 
    # {Update a subscription}[https://apidocs.chargebee.com/docs/api/subscriptions?lang=ruby#update_a_subscription]
    #
    def change_plan(plan, end_of_term=nil, prorate=nil)
      end_of_term ||= ChargebeeRails.configuration.end_of_term
      prorate ||= ChargebeeRails.configuration.proration
      chargebee_subscription = ChargeBee::Subscription.update(
        chargebee_id, { plan_id: plan.plan_id, end_of_term: end_of_term, prorate: prorate }
      ).subscription
      update(subscription_attrs(chargebee_subscription, plan))
    end

    #
    # Update plan quantity for subscription
    # * *Args*    :
    #   - +quantity+ -> the plan quantity to be updated (integer)
    #   - +end_of_term+ -> this boolean option specifies if the update takes 
    #     effect after term end, the default behavior will be as per configuration
    #   - +prorate+ -> this boolean option specifies if the updates to subscription
    #     are prorated, the default behavior will be as per configuration
    # For more details on the *updating plan quantity for subscription*, refer 
    # {Set plan quantity for subscription}[https://apidocs.chargebee.com/docs/api/subscriptions?lang=ruby#update_a_subscription]
    #
    def set_plan_quantity(quantity, end_of_term=nil, prorate=nil)
      end_of_term ||= ChargebeeRails.configuration.end_of_term
      prorate ||= ChargebeeRails.configuration.proration
      chargebee_subscription = ChargeBee::Subscription.update(
        chargebee_id, { plan_quantity: quantity, end_of_term: end_of_term, prorate: prorate }
      ).subscription
      update(subscription_attrs(chargebee_subscription, self.plan))
    end

    #
    # Remove scheduled changes to the subscription
    #
    def remove_scheduled_changes
      begin
      chargebee_subscription = ChargeBee::Subscription.remove_scheduled_changes(
        chargebee_id
      ).subscription
      update(subscription_attrs(chargebee_subscription, self.plan))
      rescue ChargeBee::InvalidRequestError
        Rails.logger.warn("No changes are scheduled for this subscription")
      end

    end

    #
    # Add or remove addons for the subscription
    # * *Args*    :
    #   - +addon_id+ -> the id of addon in chargebee
    #   - +quantity+ -> the quantity of addon, defaults to 1
    #   - +replace_addon_list+ -> this boolean option specifies if the current
    #     addon list me be replaced with the updated one, defaults to false
    # * *Returns* :
    #   - the chargebee subscription
    # For more details on the *updating addon for subscription*, refer 
    # {Manage addons for subscription}[https://apidocs.chargebee.com/docs/api/subscriptions?lang=ruby#update_a_subscription]
    #
    def manage_addons(addon_id, quantity=1, replace_addon_list=false)
      chargebee_subscription = ChargeBee::Subscription.update(
        chargebee_id, { replace_addon_list: replace_addon_list, addons: [{ id: addon_id, quantity: quantity }] }
      ).subscription
    end

    # Cancel a subscription - it will be scheduled for cancellation at term end
    # when end_of_term is passed as true. If no options are passed the 
    # default configured value for end_of_term is taken
    # * *Args*    :
    #   - +options+ -> the options hash allowed for subscription cancellation in chargebee
    # For more details on the *updating addon for subscription*, refer 
    # {Manage addons for subscription}[https://apidocs.chargebee.com/docs/api/subscriptions?lang=ruby#update_a_subscription]
    #
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

    #
    # Estimates the subscription's renewal
    # * *Args*    :
    #   - +options+ -> the options hash allowed for renewal estimate in chargebee
    # * *Returns* :
    #   - the chargebee estimate
    # For more details on the *options for renewal of estimate*, refer 
    # {Subscription renewal estimate}[https://apidocs.chargebee.com/docs/api/estimates?lang=ruby#subscription_renewal_estimate]
    #
    def estimate_renewal(options={})
      options[:include_delayed_charges] ||= ChargebeeRails.configuration.include_delayed_charges[:renewal_estimate]
      ChargeBee::Estimate.renewal_estimate(chargebee_id, options).estimate
    end

    module ClassMethods
      #
      # Estimates the cost of subscribing to a new subscription
      # * *Args*    :
      #   - +estimation_params+ -> the estimation options permitted for estimating 
      #     new subscription in chargebee
      # * *Returns* :
      #   - the chargebee estimate
      # For more details on the *estimation params for new subscription estimate*, refer 
      # {Create subscription estimate}[https://apidocs.chargebee.com/docs/api/estimates?lang=ruby#create_subscription_estimate]
      #
      def estimate(estimation_params)
        estimation_params[:trial_end] ||= 0
        ::ChargeBee::Estimate.create_subscription(estimation_params).estimate
      end

      # Estimates the cost of changes to an existing subscription
      # estimates the upgrade/downgrade or other changes
      # * *Args*    :
      #   - +estimation_params+ -> the estimation options permitted for estimating 
      #     subscription update in chargebee
      # * *Returns* :
      #   - the chargebee estimate
      # For more details on the *estimation params for subscription update estimate*, refer 
      # {Update subscription estimate}[https://apidocs.chargebee.com/docs/api/estimates?lang=ruby#update_subscription_estimate]
      #
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
