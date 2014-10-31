class VocabularyGroup < ActiveRecord::Base
  has_many :vocabulary_questions
end
