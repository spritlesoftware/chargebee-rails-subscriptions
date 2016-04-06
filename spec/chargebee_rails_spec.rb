require 'spec_helper'
require 'sample_class'

describe "chargebee_rails" do
  
  describe "#retrieve_subscriber" do
    it 'should accept a subscription owner object and return its corresponding chagrebee customer object' do
      user = User.new
      user.chargebee_id = 'IG5ryicPgRSUWg1O0h'
      customer = ChargeBee::Customer.retrieve('IG5ryicPgRSUWg1O0h').customer
      subscriber = ChargebeeRails.retrieve_subscriber(user)
      subscriber.should be_an_instance_of ChargeBee::Customer
      expect(ChargebeeRails.retrieve_subscriber(user).id).to eq(customer.id)
    end
  end

  describe "#configuration" do
    it 'should configure the default values for the application' do
      ChargebeeRails.configuration.default_plan_id.should be_nil
      ChargebeeRails.configuration.end_of_term.should be false
      ChargebeeRails.configuration.include_delayed_charges[:changes_estimate].should be false
      ChargebeeRails.configuration.include_delayed_charges[:renewal_estimate].should be true
      ChargebeeRails.configure do |config|
        config.default_plan_id = "sample_plan_id"
        config.end_of_term = true
        config.include_delayed_charges[:changes_estimate] = true
        config.include_delayed_charges[:renewal_estimate] = false
      end
      expect(ChargebeeRails.configuration.default_plan_id).to  eq("sample_plan_id")
      expect(ChargebeeRails.configuration.end_of_term).to  be true
      expect(ChargebeeRails.configuration.include_delayed_charges[:changes_estimate]).to  be true
      expect(ChargebeeRails.configuration.include_delayed_charges[:renewal_estimate]).to  be false
    end
  end
end
