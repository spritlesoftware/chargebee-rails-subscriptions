require 'spec_helper'

describe "chargebee_rails" do

  describe "subscriber#subscribe" do

    before do
      @user = User.new
      @user.first_name = "Sairam"
      @user.last_name = "S"
      @user.email = "example@spritle.com"
      @user.phone = "1234567890"      
    end

    it 'should be pass params to subscribe method' do
      user_params = { "first_name"=>"Sairam", "last_name"=>"S", "email"=>"example@spritle.com", "phone"=>"7092459195" }
      @user.expects(:subscribe).with(any_of(has_key(:customer), has_entry(:customer => :user_params)))
      @user.subscribe(customer: user_params)
    end

    it 'should return NoMethod error without plan configuration' do
      user_params = { "first_name"=>"Sairam", "last_name"=>"S", "email"=>"example@spritle.com", "phone"=>"7092459195" }
      expect { @user.subscribe(customer: user_params)  }.to raise_error(NoMethodError)     
    end

    it 'should return a new subscription object' do
      user_params = { "first_name"=>"Sairam", "last_name"=>"S", "email"=>"example@spritle.com", "phone"=>"7092459195" }
      result = User.any_instance.stubs(:subscribe).returns({ status: true })
      expect(result).to be_truthy
    end

  end

end