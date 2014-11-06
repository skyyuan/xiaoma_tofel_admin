class CreateTpoGroups < ActiveRecord::Migration
  def change
    create_table :tpo_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
