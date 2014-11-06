class CreateOralGroups < ActiveRecord::Migration
  def change
    create_table :oral_groups do |t|
      t.string :sequence_number

      t.timestamps
    end
  end
end
