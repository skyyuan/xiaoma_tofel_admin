class JijingQuestion < ActiveRecord::Base
  belongs_to :jijing_group
  has_many :jijing_samples
end
