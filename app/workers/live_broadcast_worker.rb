# encoding: utf-8

require 'rufus-scheduler'
class LiveBroadcastWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :live_broadcast_status

  def perform(live_broadcast_id)
    scheduler = Rufus::Scheduler.new
    live_broadcast = LiveBroadcast.find(live_broadcast_id)

    now_time = Time.now
    start_at = live_broadcast.start_at
    end_at = live_broadcast.end_at
    first_at = now_time + (start_at - now_time).to_i
    last_at = now_time + (end_at - now_time).to_i

    interval = (end_at - start_at).to_i
    interval = interval > 0 ? interval : 0

    scheduler.every "#{interval}s", :first_at => first_at, :last_at => last_at + 10 do
      live_broadcast.update(status: '3') if live_broadcast.status == '2'
      live_broadcast.update(status: '2') if live_broadcast.status == '1'
    end
  end
end
