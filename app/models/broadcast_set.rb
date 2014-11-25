class BroadcastSet < ActiveRecord::Base
  attr_accessible :title, :description, :cover, :subscribe_count
  has_many :recorded_broadcasts
end
