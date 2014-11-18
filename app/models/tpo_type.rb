class TpoType < ActiveRecord::Base
  READ_TYPE = {1 => 'Passage1', 2 => 'Passage2', 3 => 'Passage3'}
  LISTEN_TYPE = {1 => 'Conversion1', 2 => 'Conversion2', 3 => 'Lecture1', 4 => 'Lecture2', 5 => 'Lecture3', 6 => 'Lecture4'}
  LISTEN_CONVERSION_TYPE = 'Conversion'
  LISTEN_LECTURE_TYPE = 'lECTURE'

  belongs_to :tpo_group
  has_many :tpo_questions
end
