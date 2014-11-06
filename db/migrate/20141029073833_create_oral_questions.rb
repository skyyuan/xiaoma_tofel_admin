class CreateOralQuestions < ActiveRecord::Migration
  def change
    create_table :oral_questions do |t|
      t.string :sequence_number
      t.string :data_url
      t.text :original_text
      t.references :oral_group, index: true

      t.timestamps
    end
  end
end
