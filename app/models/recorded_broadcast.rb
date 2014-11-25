class RecordedBroadcast < ActiveRecord::Base
  attr_accessible :title, :cover, :summary, :video_url, :broadcast_set_id, :rb_favorites_count, :play_count
  belongs_to :broadcast_set
end
