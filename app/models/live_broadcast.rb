# encoding: utf-8
class LiveBroadcast < ActiveRecord::Base
  attr_accessible :title, :cover, :summary, :video_url, :status, :start_at, :end_at, :teacher

  def status_name
    if self.status.to_i == 1
      "未开始"
    elsif self.status.to_i == 2
      "正在直播"
    elsif self.status.to_i == 3
      "已结束"
    end
  end
end
