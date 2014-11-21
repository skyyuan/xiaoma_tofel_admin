class AddPlayCountToRecordedBroadcasts < ActiveRecord::Migration
  def change
    add_column :recorded_broadcasts, :play_count, :integer, default: 0
  end
end
