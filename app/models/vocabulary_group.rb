class VocabularyGroup < ActiveRecord::Base
  has_many :vocabulary_questions
  attr_accessible :sequence_number
end
