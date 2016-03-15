class Subscription < ActiveRecord::Base
  belongs_to :<%= subscription_owner_model %>
  belongs_to :plan
  has_one :card
  include ChargebeeRails::ChargeableSubscription
end
