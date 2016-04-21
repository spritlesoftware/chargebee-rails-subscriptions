module ChargebeeRails
  module Subscriber

    # Subscribe customer to a new subscription
    def subscribe(options={})
      SubscriptionBuilder.new(self, options).create
    end

    # Subscribe customer to a new subscription via hosted page
    def subscribe_via_hosted_page(hosted_page)
      HostedPageSubscriptionManager.new(self, hosted_page).create
    end

    def update_subscription_via_hosted_page(hosted_page)
      HostedPageSubscriptionManager.new(self, hosted_page).update
    end

    def update_subscription(options={})
      SubscriptionBuilder.new(self, options).update
    end

    # Retrieve subscriber as chargebee customer
    def as_chargebee_customer
      ChargeBee::Customer.retrieve(chargebee_id).customer
    end

    # List all invoices for the customer
    def invoices
      ChargeBee::Invoice.invoices_for_customer(chargebee_id).map(&:invoice)
    end

  end
end
