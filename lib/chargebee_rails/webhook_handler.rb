module ChargebeeRails
  module WebhookHandler

    # Handle the ChargeBee event retrieved from webhook and call the
    # corresponding event type handler for the event
    def handle(chargebee_event)
      @chargebee_event = chargebee_event
      handle_remote_chargebee_subscription_updates if check_subscription_update
      send(event.event_type)
    end

    # Set event as ChargeBee event
    def event
      @event ||= @chargebee_event
    end

    # All the event types in ChargeBee

    def customer_created; end

    def customer_changed; end

    def customer_deleted; end

    def subscription_created; end

    def subscription_started; end

    def subscription_trial_ending; end

    def subscription_activated; end

    def subscription_changed; end

    def subscription_cancellation_scheduled; end

    def subscription_cancellation_reminder; end

    def subscription_cancelled; end

    def subscription_reactivated; end

    def subscription_renewed; end

    def subscription_scheduled_cancellation_removed; end

    def subscription_shipping_address_updated; end

    def subscription_deleted; end

    def invoice_created
      ChargeBee::Invoice.collect(@event.content.invoice.id)
    end

    def invoice_generated; end

    def invoice_updated; end

    def invoice_deleted; end

    def credit_note_created; end

    def credit_note_updated; end
    
    def credit_note_deleted; end

    def subscription_renewal_reminder; end

    def transaction_created; end

    def transaction_updated; end

    def transaction_deleted; end

    def payment_succeeded; end

    def payment_failed; end

    def payment_refunded; end

    def payment_initiated; end
    
    def refund_initiated; end
    
    def card_added; end

    def card_updated; end

    def card_expiry_reminder; end

    def card_expired; end

    def card_deleted; end

    private

    def check_subscription_update
      remote_subscription_events.include? event.event_type
    end

    def handle_remote_chargebee_subscription_updates
      subscription_event = event.content.subscription
      subscription = ::Subscription.find_by(chargebee_id: subscription_event.id)
      subscription.update(
        chargebee_plan: subscription_event.plan_id,
        plan: ::Plan.find_by(plan_id: subscription_event.plan_id),
        status: subscription_event.status,
        has_scheduled_changes: subscription_event.has_scheduled_changes
      ) if subscription.try(:has_scheduled_changes)
    end

    def remote_subscription_events
      %w( subscription_activated subscription_changed subscription_renewed subscription_cancelled )
    end

  end
end
