class CreateJijingQuestions < ActiveRecord::Migration
  def change
    create_table :jijing_questions do |t|
      t.string :sequence_number
      t.references :jijing_task, index: true
      t.text :content

      t.timestamps
    end
  end
end
