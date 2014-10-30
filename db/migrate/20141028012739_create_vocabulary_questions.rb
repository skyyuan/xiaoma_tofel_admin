class CreateVocabularyQuestions < ActiveRecord::Migration
  def change
    create_table :vocabulary_questions do |t|
      t.string :sequence_number
      t.text :content
      t.references :vocabulary_group, index: true

      t.timestamps
    end
  end
end
