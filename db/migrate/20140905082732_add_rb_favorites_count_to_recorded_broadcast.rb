class AddRbFavoritesCountToRecordedBroadcast < ActiveRecord::Migration
  def change
    add_column :recorded_broadcasts, :rb_favorites_count, :integer, default: 0
  end
end
