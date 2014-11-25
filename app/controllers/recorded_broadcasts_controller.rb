# encoding: utf-8
class RecordedBroadcastsController < ApplicationController
  def index
    @recorded_broadcasts = RecordedBroadcast.order("created_at desc")
  end

  def new
    @recorded_broadcast = RecordedBroadcast.new
  end

  def create
    @recorded_broadcast = RecordedBroadcast.new(params[:recorded_broadcast])
    @recorded_broadcast.save
    redirect_to recorded_broadcasts_path
  end

  def edit
    @recorded_broadcast = RecordedBroadcast.find params[:id]
  end

  def update
    @recorded_broadcast = RecordedBroadcast.find params[:id]
    @recorded_broadcast.update_attributes(params[:recorded_broadcast])
    redirect_to recorded_broadcasts_path
  end

  def destroy
    @broadcast_set = RecordedBroadcast.find params[:id]
    @broadcast_set.destroy
    redirect_to recorded_broadcasts_path
  end
end
