class CreateJijingWorks < ActiveRecord::Migration
  def change
    create_table :jijing_works do |t|
      t.string :sequence_number
      t.references :jijing_group, index: true
      t.text :content
      t.string :content_type

      t.timestamps
    end
  end
end
