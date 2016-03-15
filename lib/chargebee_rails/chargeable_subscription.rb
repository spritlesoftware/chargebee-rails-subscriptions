module ChargebeeRails
  module ChargeableSubscription
    def change_plan(plan)
     result = ChargeBee::Subscription.update(chargebee_id, { plan_id: plan.plan_id })
     subscription = result.subscription
     update(
      chargebee_plan: subscription.plan_id, 
      plan_id: plan.id,
      status: subscription.status
    )
    end

    def cancel
      result = ChargeBee::Subscription.cancel(chargebee_id)
      subscription = result.subscription
      update(
        status: subscription.status
      )
    end

    def reactivate
      result = ChargeBee::Subscription.reactivate(chargebee_id)
      subscription = result.subscription
      update(
        status: subscription.status
      )
    end
  end
end
