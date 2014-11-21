class CreateBroadcastSets < ActiveRecord::Migration
  def change
    create_table :broadcast_sets do |t|
      t.string :title
      t.text :description
      t.string :cover

      t.timestamps
    end
  end
end
