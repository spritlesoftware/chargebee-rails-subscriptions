# :nodoc:all
module ChargebeeRails
  module WebhookHandler

    # Handle the ChargeBee event retrieved from webhook and call the
    # corresponding event type handler for the event
    def handle(chargebee_event)
      @chargebee_event = chargebee_event
      if sync_events_list.include?(event.event_type)
        sync_events
    elsif self.respond_to?(event.event_type)
        send(event.event_type)
    else
        Rails.logger.warn("Unrecognised chargebee event type #{event.event_type}")
    end

    end

    # Set event as ChargeBee event
    def event
      @event ||= @chargebee_event
    end

    # All the event types in ChargeBee as of API V2

    def plan_created; end

    def plan_updated; end

    def plan_deleted; end

    def addon_created; end

    def addon_updated; end

    def addon_deleted; end

    def coupon_created; end

    def coupon_updated; end

    def coupon_deleted; end

    def coupon_set_created; end

    def coupon_set_updated; end

    def coupon_set_deleted; end

    def coupon_codes_added; end

    def coupon_codes_deleted; end

    def coupon_codes_updated; end

    def customer_created; end

    def customer_changed; end

    def customer_deleted; end

    def customer_moved_out; end

    def customer_moved_in; end

    def subscription_created; end

    def subscription_started; end

    def subscription_trial_end_reminder; end

    def subscription_activated; end

    def subscription_changed; end

    def subscription_cancellation_scheduled; end

    def subscription_cancellation_reminder; end

    def subscription_cancelled; end

    def subscription_reactivated; end

    def subscription_renewed; end

    def subscription_scheduled_cancellation_removed; end

    def subscription_changes_scheduled; end

    def subscription_scheduled_changes_removed; end

    def subscription_shipping_address_updated; end

    def subscription_deleted; end

    def pending_invoice_created
      ::ChargebeeRails::MeteredBilling.close_invoice(@event.content.invoice.id)
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

    def netd_payment_due_reminder; end

    def card_added; end

    def card_updated; end

    def card_expiry_reminder; end

    def card_expired; end

    def card_deleted; end

    def payment_source_added; end

    def payment_source_updated; end

    def payment_source_deleted; end

    def unbilled_charges_created; end

    def unbilled_charges_voided; end

    def unbilled_charges_deleted; end

    def unbilled_charges_invoiced; end


    private

    def sync_events_list
      %w( 
        card_expired
        card_updated
        card_expiry_reminder
        subscription_started
        subscription_trial_end_reminder
        subscription_activated
        subscription_changed
        subscription_cancellation_scheduled
        subscription_cancellation_reminder
        subscription_cancelled
        subscription_reactivated
        subscription_renewed
        subscription_scheduled_cancellation_removed
        subscription_renewal_reminder
      )
    end

    def sync_events
      sync(existing_subscription, subscription_attrs(event.content.subscription)) if event.event_type.include?('subscription') && can_sync?(existing_subscription)
      sync(existing_payment_method, payment_method_attrs(event.content.customer, event.content.card)) if event.event_type.include?('card') && event.content.customer.payment_method.present? && can_sync?(existing_payment_method)
    end

    def sync obj, attrs
      obj.update_all(attrs)
      send(event.event_type)
    end

    def existing_subscription
      @existing_subscription ||= ::Subscription.where(chargebee_id: event.content.subscription.id)
    end

    def existing_payment_method
      @existing_payment_method ||= ::PaymentMethod.where(cb_customer_id: event.content.customer.id)
    end

    def can_sync? obj
      obj.first && (obj.first.event_last_modified_at.to_i < event.occurred_at)
    end

    def subscription_attrs subscription
      {
        chargebee_id: subscription.id,
        plan_id: ::Plan.find_by(plan_id: subscription.plan_id).id,
        plan_quantity: subscription.plan_quantity,
        status: subscription.status,
        event_last_modified_at: Time.at(event.occurred_at),
        updated_at: Time.now,
        chargebee_data: chargebee_subscription_data(subscription)
      }
    end

    def chargebee_subscription_data subscription
      {
        trial_ends_at: subscription.trial_end,
        next_renewal_at: subscription.current_term_end,
        cancelled_at: subscription.cancelled_at,
        is_scheduled_for_cancel: (subscription.status == 'non-renewing' ? true : false),
        has_scheduled_changes: subscription.has_scheduled_changes,
        addons: subscription.addons
      }
    end

    def payment_method_attrs customer, card
      {
        cb_customer_id: customer.id,
        auto_collection: customer.auto_collection,
        payment_type: customer.payment_method.type,
        reference_id: customer.payment_method.reference_id,
        card_last4: card.last4,
        card_type: card.card_type,
        status: customer.payment_method.status,
        event_last_modified_at: Time.at(event.occurred_at),
        updated_at: Time.now
      }
    end

  end
end
