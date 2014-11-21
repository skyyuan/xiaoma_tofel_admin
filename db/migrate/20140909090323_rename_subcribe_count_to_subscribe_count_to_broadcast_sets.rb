class RenameSubcribeCountToSubscribeCountToBroadcastSets < ActiveRecord::Migration
  def change
    rename_column :broadcast_sets, :subcribe_count, :subscribe_count
  end
end
