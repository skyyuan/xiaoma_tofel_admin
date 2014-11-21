#encoding: utf-8
class LiveBroadcastsController < ApplicationController
  def index
    @live_broadcasts = LiveBroadcast.order("created_at desc").page(params[:page])
  end

  def new
    @live_broadcast = LiveBroadcast.new
  end

  def create
    @live_broadcast = LiveBroadcast.new(params[:live_broadcast])
    if @live_broadcast.save
      redirect_to live_broadcasts_path
    else
      redirect_to new_live_broadcast_path
    end
  end

  def edit
    @live_broadcast = LiveBroadcast.find params[:id]
  end

  def update
    @live_broadcast = LiveBroadcast.find params[:id]
    if @live_broadcast.update_attributes(params[:live_broadcast])
      redirect_to live_broadcasts_path
    else
      redirect_to edit_live_broadcast_path(@live_broadcast)
    end
  end

  def destroy
    @live_broadcast = LiveBroadcast.find params[:id]
    @live_broadcast.destroy
    redirect_to live_broadcasts_path
  end
end
