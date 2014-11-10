class TpoType < ActiveRecord::Base
  belongs_to :tpo_group
  has_many :tpo_questions
end
