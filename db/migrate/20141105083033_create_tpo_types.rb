class CreateTpoTypes < ActiveRecord::Migration
  def change
    create_table :tpo_types do |t|
      t.string :name
      t.references :tpo_group, index: true

      t.timestamps
    end
  end
end
