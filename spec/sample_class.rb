class User
  include ChargebeeRails::Customer
  attr_accessor :chargebee_id, :first_name, :last_name, :email, :phone
end
