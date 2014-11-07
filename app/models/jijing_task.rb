class JijingTask < ActiveRecord::Base
  belongs_to :jijing_group
  has_many :jijing_questions
end
