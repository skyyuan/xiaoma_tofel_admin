class CreateTpoQuestions < ActiveRecord::Migration
  def change
    create_table :tpo_questions do |t|
      t.text :content
      t.integer :sequence_number
      t.references :tpo_type, index: true

      t.timestamps
    end
  end
end
