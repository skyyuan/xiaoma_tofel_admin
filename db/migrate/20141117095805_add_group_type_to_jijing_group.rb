class AddGroupTypeToJijingGroup < ActiveRecord::Migration
  def change
    add_column :jijing_groups, :group_type, :string
  end
end
