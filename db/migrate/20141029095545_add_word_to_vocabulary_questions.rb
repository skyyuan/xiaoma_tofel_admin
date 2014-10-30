class AddWordToVocabularyQuestions < ActiveRecord::Migration
  def change
    add_column :vocabulary_questions, :word, :string
  end
end
