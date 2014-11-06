class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :content
      t.string :tip
      t.string :related_resource
      t.integer :set
      t.integer :number
      t.string :subject
      t.string :source
      t.string :difficulty

      t.timestamps
    end
  end
end
