class TpoType < ActiveRecord::Base
  READ_TYPE = {1 => 'Passage1', 2 => 'Passage2', 3 => 'Passage3'}
  LISTEN_TYPE = {1 => 'conversation1', 2 => 'conversation2', 3 => 'lecture1', 4 => 'lecture2', 5 => 'lecture3', 6 => 'lecture4'}
  LISTEN_CONVERSION_TYPE = 'conversation'
  LISTEN_LECTURE_TYPE = 'lecture'

  belongs_to :tpo_group
  has_many :tpo_questions
end
