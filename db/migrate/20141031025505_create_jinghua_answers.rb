class CreateJinghuaAnswers < ActiveRecord::Migration
  def change
    create_table :jinghua_answers do |t|
      t.references :user, index: true
      t.references :jinghua_question, index: true
      t.string :content
      t.string :is_shared

      t.timestamps
    end
  end
end
