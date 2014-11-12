# encoding: utf-8
class JijingWorksController < ApplicationController
  def index
    @works = JijingWork.order("created_at desc").page(params[:page])
  end

  def new_group
    @jijing_groups = JijingGroup.order("created_at desc")
  end

  def new_type
  end

  def new

  end

  def create
    work = JijingWork.new
    work.content = params[:content]
    work.content_type = params[:type_name]
    work.sequence_number = params[:number]
    work.jijing_group_id = params[:group_id]
    if work.save
      if params[:resolution].present?
        WorkResolution.create(content: params[:resolution],jijing_work_id: work.id)
      end
      if params[:sample].present?
        WorkSample.create(standpoint: 1, content: params[:sample],jijing_work_id: work.id,user_id: 1)
      end
      redirect_to jijing_works_path
    else
      redirect_to new_jijing_work(type_name: params[:type_name],number:params[:number],group_id: params[:group_id])
    end
  end

end
