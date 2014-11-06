class CreateReproductionQuestions < ActiveRecord::Migration
  def change
    create_table :reproduction_questions do |t|
      t.text :content
      t.string :sequence_number

      t.timestamps
    end
  end
end
