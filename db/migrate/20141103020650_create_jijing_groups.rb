class CreateJijingGroups < ActiveRecord::Migration
  def change
    create_table :jijing_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
