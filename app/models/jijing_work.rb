class JijingWork < ActiveRecord::Base
  belongs_to :jijing_group
  has_many :work_resolutions
  has_many :work_samples
end