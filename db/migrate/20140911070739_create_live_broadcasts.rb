class CreateLiveBroadcasts < ActiveRecord::Migration
  def change
    create_table :live_broadcasts do |t|
      t.string :title
      t.string :cover
      t.text :summary
      t.string :video_url
      t.datetime :start_at
      t.string :status

      t.timestamps
    end
  end
end
