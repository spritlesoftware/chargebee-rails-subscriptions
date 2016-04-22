module ChargebeeRails
  module Card

    # Retrive the card information for a customer
    def as_chargebee_card
      ChargeBee::Card.retrieve(cb_customer_id).card
    end

  end
end
