class CreateJijingTasks < ActiveRecord::Migration
  def change
    create_table :jijing_tasks do |t|
      t.string :name
      t.references :jijing_group, index: true

      t.timestamps
    end
  end
end
