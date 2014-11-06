class AddOralOriginToOralGroups < ActiveRecord::Migration
  def change
    add_reference :oral_groups, :oral_origin, index: true
  end
end
