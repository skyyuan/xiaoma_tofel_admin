class CreateOralOrigins < ActiveRecord::Migration
  def change
    create_table :oral_origins do |t|
      t.string :name

      t.timestamps
    end
  end
end
