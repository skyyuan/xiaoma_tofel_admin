class CreateDictationGroups < ActiveRecord::Migration
  def change
    create_table :dictation_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
