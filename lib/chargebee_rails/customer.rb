module ChargebeeRails
  module Customer

    # Subscribe customer to a new subscription in chargebee.
    # * *Args*    :
    #   - +options+ -> the options hash allowed for subscription update in chargebee 
    # For more details on the options hash, refer the input parameters for
    # https://apidocs.chargebee.com/docs/api/subscriptions?lang=ruby#create_a_subscription
    # * *Returns* :
    #   - the subscription
    # * *Raises*  :
    #   - +ChargeBee::InvalidRequestError+ -> If subscription options is invalid
    #
    def subscribe(options={})
      SubscriptionBuilder.new(self, options).create
    end

    # Subscribe customer to a new subscription in chargebee via chargebee's hosted page.
    # * *Args*    :
    #   - +hosted_page+ -> the +hosted_page+ returned by chargebee 
    # The subscription for the customer is created from the +hosted_page+ 
    # returned by chargebee. This +hosted_page+ object contains the details 
    # about the subscription in chargebee for the customer. For more on +hosted_page+
    # https://apidocs.chargebee.com/docs/api/hosted_pages?lang=ruby#checkout_new_subscription
    # * *Returns* :
    #   - the subscription
    # * *Raises*  :
    #   - +ChargeBee::InvalidRequestError+ -> If +hosted_page+ is invalid
    #
    def subscribe_via_hosted_page(hosted_page)
      HostedPageSubscriptionManager.new(self, hosted_page).create
    end

    # Subscribe customer to a new subscription in chargebee via chargebee's hosted page.
    # * *Args*    :
    #   - +hosted_page+ -> the +hosted_page+ returned by chargebee 
    # The subscription for the customer is updated from the +hosted_page+ 
    # returned by chargebee. This +hosted_page+ object contains the details 
    # about the updated subscription in chargebee for the customer. 
    # * *Returns* :
    #   - the subscription
    # * *Raises*  :
    #   - +ChargeBee::InvalidRequestError+ -> If +hosted_page+ is invalid
    #
    def update_subscription_via_hosted_page(hosted_page)
      HostedPageSubscriptionManager.new(self, hosted_page).update
    end

    # Update the customer's subscription
    # * *Args*    :
    #   - +options+ -> the options hash allowed for subscription update in chargebee 
    # For more details on the options hash, refer the input parameters for
    # https://apidocs.chargebee.com/docs/api/subscriptions?lang=ruby#update_a_subscription
    # * *Returns* :
    #   - the updated subscription
    # * *Raises*  :
    #   - +ChargeBee::InvalidRequestError+ -> If subscription or options is invalid
    #
    def update_subscription(options={})
      SubscriptionBuilder.new(self, options).update
    end

    # Retrieve the chargebee customer of the subscription owner -
    # i.e subscription owner as chargebee customer
    # * *Returns* :
    #   - the chargebee customer
    # * *Raises*  :
    #   - +ChargeBee::InvalidRequestError+ -> If subscription owner is invalid
    #
    def as_chargebee_customer
      ChargeBee::Customer.retrieve(chargebee_id).customer
    end

    # List all invoices for the subscription owner (customer).
    # * *Returns* :
    #   - the list of invoices for the customer in chargebee
    # * *Raises*  :
    #   - +ChargeBee::InvalidRequestError+ -> If customer is invalid
    #
    def invoices
      ChargeBee::Invoice.invoices_for_customer(chargebee_id).map(&:invoice)
    end

  end
end
