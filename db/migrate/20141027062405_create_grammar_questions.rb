class CreateGrammarQuestions < ActiveRecord::Migration
  def change
    create_table :grammar_questions do |t|
      t.string :sequence_number
      t.text :content
      t.references :grammar_group, index: true

      t.timestamps
    end
  end
end
