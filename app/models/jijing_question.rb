class JijingQuestion < ActiveRecord::Base
  attr_accessible :content, :analysis, :sequence_number, :jijing_group_id
  belongs_to :jijing_group
  has_one :jijing_sample
end
