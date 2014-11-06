class AddNameToOralGroup < ActiveRecord::Migration
  def change
    add_column :oral_groups, :name, :string
  end
end
