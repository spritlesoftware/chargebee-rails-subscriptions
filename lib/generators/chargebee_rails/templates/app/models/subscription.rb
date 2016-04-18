class Subscription < ActiveRecord::Base
  belongs_to :<%= subscriber_model %>
  belongs_to :plan
  has_one :card
  include ChargebeeRails::ChargeableSubscription
end
