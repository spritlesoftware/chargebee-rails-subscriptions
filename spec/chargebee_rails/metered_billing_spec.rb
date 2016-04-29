require 'spec_helper'

describe "chargebee_rails" do
  describe "#metered billing" do

    let(:metered_billing) { ChargebeeRails::MeteredBilling }

    it 'passes correct params to add_charge method' do
      metered_billing.expects(:add_charge).with("draft_inv23423", "50", "New Plan")
      metered_billing.add_charge("draft_inv23423", "50", "New Plan")
    end

    it '#add_charge method raise argument error to in-correct params' do
      expect { metered_billing.add_charge("draft_inv23423", "50")  }.to raise_error(ArgumentError) 
    end    

    it 'passes correct params to add_addon_charge method' do
      metered_billing.expects(:add_addon_charge).with("draft_inv23423", "ssl", optionally("3"))
      metered_billing.add_addon_charge("draft_inv23423", "ssl", "3")
    end

    it '#add_addon_charge method raise argument error to in-correct params' do
      expect { metered_billing.add_addon_charge("draft_inv23423")  }.to raise_error(ArgumentError) 
    end

    it 'raise API error to invalid invoice_id' do
      expect { metered_billing.add_charge("draft_inv23423", "50", "New Plan")  }.to raise_error(ChargeBee::APIError)
      expect { metered_billing.add_addon_charge("draft_inv23423", "ssl")  }.to raise_error(ChargeBee::APIError)
      expect { metered_billing.close_invoice("draft_inv23423")  }.to raise_error(ChargeBee::APIError) 
    end

  end
end