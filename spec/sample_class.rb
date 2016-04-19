class User
  include ChargebeeRails::Subscriber
  attr_accessor :chargebee_id, :first_name, :last_name, :email, :phone
end
