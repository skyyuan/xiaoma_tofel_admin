class CreateJinghuaQuestions < ActiveRecord::Migration
  def change
    create_table :jinghua_questions do |t|
      t.text :content
      t.string :type

      t.timestamps
    end
  end
end
