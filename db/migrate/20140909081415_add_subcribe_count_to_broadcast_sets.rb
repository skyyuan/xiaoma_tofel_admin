class AddSubcribeCountToBroadcastSets < ActiveRecord::Migration
  def change
    add_column :broadcast_sets, :subcribe_count, :integer, default: 0
  end
end
