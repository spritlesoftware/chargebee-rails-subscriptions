module ChargebeeRails
  module ChargeableSubscription
    def change_plan(plan, end_of_term=false)
      subscription = ChargeBee::Subscription.update(
        chargebee_id, { plan_id: plan.plan_id, end_of_term: end_of_term }
      ).subscription
      update(
        chargebee_plan: subscription.plan_id, 
        plan_id: plan.id,
        status: subscription.status
      ) unless end_of_term
    end

    def cancel(end_of_term=false)
      subscription = ChargeBee::Subscription.cancel(chargebee_id).subscription
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
  end
end
