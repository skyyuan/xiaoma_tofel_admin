# encoding: utf-8
class BroadcastSetsController < ApplicationController
  def index
    @broadcast_sets = BroadcastSet.order("created_at desc")
  end

  def new
    @broadcast_set = BroadcastSet.new
  end

  def edit
    @broadcast_set = BroadcastSet.find params[:id]
  end

  def create
    @broadcast_set = BroadcastSet.new(params[:broadcast_set])
    @broadcast_set.save
    redirect_to broadcast_sets_path
  end

  def update
    @broadcast_set = BroadcastSet.find params[:id]
    @broadcast_set.update_attributes(params[:broadcast_set])
    redirect_to broadcast_sets_path
  end

  def destroy
    @broadcast_set = BroadcastSet.find params[:id]
    @broadcast_set.destroy
    redirect_to broadcast_sets_path
  end
end
