class TpoType < ActiveRecord::Base
  READ_TYPE = {1 => 'Passage1', 2 => 'Passage2', 3 => 'Passage3'}

  belongs_to :tpo_group
  has_many :tpo_questions
end
