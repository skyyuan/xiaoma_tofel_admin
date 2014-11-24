class AddTeacherAndEndAtToLiveBroadcasts < ActiveRecord::Migration
  def change
    add_column :live_broadcasts, :teacher, :string
    add_column :live_broadcasts, :end_at, :datetime
  end
end
