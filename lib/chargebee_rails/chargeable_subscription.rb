module ChargebeeRails
  module ChargeableSubscription

    def self.included(base)
      base.extend(ClassMethods)
    end

    def as_chargebee_subscription
      ChargeBee::Subscription.retrieve(chargebee_id).subscription
    end

    def change_plan(plan, options={})
      options[:plan_id] = plan.plan_id
      options[:end_of_term] ||= ChargebeeRails.configuration.end_of_term
      subscription = ChargeBee::Subscription.update(chargebee_id, options).subscription
      update(
        chargebee_plan: subscription.plan_id,
        plan_id: plan.id,
        status: subscription.status
      ) unless options[:end_of_term]
    end

    def cancel(options={})
      options[:end_of_term] ||= ChargebeeRails.configuration.end_of_term
      subscription = ChargeBee::Subscription.cancel(chargebee_id, options).subscription
      update(
        status: subscription.status
      ) unless end_of_term
    end

    def stop_cancellation
      ChargeBee::Subscription.remove_scheduled_cancellation(chargebee_id).subscription
    end

    def reactivate
      subscription = ChargeBee::Subscription.reactivate(chargebee_id).subscription
      update(
        status: subscription.status
      )
    end

    def renewal_estimate(options={})
      options[:include_delayed_charges] ||= ChargebeeRails.configuration.include_delayed_charges[:renewal_estimate]
      ChargeBee::Estimate.renewal_estimate(chargebee_id, options).estimate
    end

    module ClassMethods 
      
      def estimate(estimation_params)
        ::ChargeBee::Estimate.create_subscription(estimation_params).estimate
      end

      def estimate_changes(estimation_params)
        estimation_params[:include_delayed_charges] ||= ChargebeeRails.configuration.include_delayed_charges[:changes_estimate]
        ::ChargeBee::Estimate.update_subscription(estimation_params).estimate
      end

    end

  end
end
