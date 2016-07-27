module ChargebeeRails
  class MeteredBilling
    class << self

      #
      # Add charge to pending invoice
      # * *Args*    :
      #   - +invoice_id+ -> the pending invoice id
      #   - +amount+ -> the charge on item to be added
      #   - +description+ -> the description of the added item
      # * *Returns* :
      #   - the chargebee pending invoice
      # For more details on the +add_charge+ for pending invoice, refer 
      # {Add charge item to pending invoice}[https://apidocs.chargebee.com/docs/api/invoices?lang=ruby#add_charge_item_to_pending_invoice]
      #
      def add_charge(invoice_id, amount, description)
        ChargeBee::Invoice.add_charge(invoice_id, {
          amount: amount, 
          description: description
        }).invoice
      end

      #
      # Add addon charge to pending invoice
      # * *Args*    :
      #   - +invoice_id+ -> the pending invoice id
      #   - +addon_id+ -> the id of the addon in chargebee
      #   - +addon_quantity+ -> the quantity of addon, defaults to 1
      # * *Returns* :
      #   - the chargebee pending invoice
      # For more details on the +addon_charge+ for pending invoice, refer 
      # {Add addon item to pending invoice}[https://apidocs.chargebee.com/docs/api/invoices?lang=ruby#add_addon_item_to_pending_invoice]
      #
      def add_addon_charge(invoice_id, addon_id, addon_quantity=1)
        ChargeBee::Invoice.add_addon_charge(invoice_id, {
          addon_id: addon_id,
          addon_quantity: addon_quantity
        }).invoice
      end

      #
      # Close pending invoice
      # * *Args*    :
      #   - +invoice_id+ -> the pending invoice id
      # * *Returns* :
      #   - the chargebee invoice
      # For more details on closing pending invoice, refer 
      # {Close a pending invoice}[https://apidocs.chargebee.com/docs/api/invoices?lang=ruby#close_a_pending_invoice]
      #
      def close_invoice(invoice_id)
        ChargeBee::Invoice.close(invoice_id).invoice
      end

    end
  end
end
