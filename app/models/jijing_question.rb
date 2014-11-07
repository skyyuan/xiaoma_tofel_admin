class JijingQuestion < ActiveRecord::Base
  belongs_to :jijing_task
  has_many :jijing_samples
end
