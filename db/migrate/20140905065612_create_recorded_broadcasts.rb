class CreateRecordedBroadcasts < ActiveRecord::Migration
  def change
    create_table :recorded_broadcasts do |t|
      t.string :title
      t.string :cover
      t.text :summary
      t.string :video_url
      t.references :broadcast_set, index: true

      t.timestamps
    end
  end
end
