class JijingSample < ActiveRecord::Base
  attr_accessible :content
  belongs_to :jijing_question
end
