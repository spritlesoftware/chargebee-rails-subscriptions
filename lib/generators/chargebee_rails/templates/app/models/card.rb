class Card < ActiveRecord::Base
  belongs_to :subscription
  include ChargebeeRails::Card
end
