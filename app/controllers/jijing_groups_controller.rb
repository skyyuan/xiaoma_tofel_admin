# encoding: utf-8
class JijingGroupsController < ApplicationController
  def index
    @jijing_groups = JijingGroup.order("created_at desc")
  end

  def create
    if params[:name].present?
      jijing_group = JijingGroup.new
      jijing_group.name = params[:name]
      jijing_group.save
      if params[:type].present?
        redirect_to new_group_jijing_works_path
      else
        redirect_to jijing_groups_path
      end
    else
      redirect_to jijing_groups_path, notice: "请输入机经!" and return
    end
  end
end