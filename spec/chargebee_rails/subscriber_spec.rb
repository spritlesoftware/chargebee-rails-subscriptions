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

    it 'should return NoMethod error without plan configuration' do
      user_params = { "first_name"=>"Sairam", "last_name"=>"S", "email"=>"example@spritle.com", "phone"=>"7092459195" }
      expect { @user.subscribe(customer: user_params)  }.to raise_error(NoMethodError)     
    end

  end

end