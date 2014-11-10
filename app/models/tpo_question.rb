class TpoQuestion < ActiveRecord::Base
  belongs_to :tpo_type
  has_many :tpo_resolutions
  has_many :tpo_samples
end
