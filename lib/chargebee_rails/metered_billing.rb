module ChargebeeRails
  class MeteredBilling
    class << self

      # Add charge to pending invoice
      def add_charge(invoice_id, amount, description)
        ChargeBee::Invoice.add_charge(invoice_id, {
          :amount => amount, 
          :description => description
        }).invoice
      end

      # Add addon charge to pending invoice
      def add_addon_charge(invoice_id, addon_id, addon_quantity=1)
        ChargeBee::Invoice.add_addon_charge(invoice_id, {
          :addon_id => addon_id,
          :addon_quantity => addon_quantity
        }).invoice
      end

      # Close pending invoice
      def close_invoice(invoice_id)
        ChargeBee::Invoice.collect(invoice_id).invoice
      end

    end
  end
end
