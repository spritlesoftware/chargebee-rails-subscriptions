class Plan < ActiveRecord::Base
  has_many :subscriptions
  serialize :chargebee_data, JSON
end
