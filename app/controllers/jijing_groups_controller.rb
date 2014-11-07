class JijingGroupsController < ApplicationController
  def index
    @jijing_groups = JijingGroup.order("created_at desc")
  end

  def create
    jijing_group = JijingGroup.new
    jijing_group.name = params[:name]
    jijing_group.save
    if params[:type].present?
      redirect_to new_group_jijing_works_path
    else
      redirect_to jijing_groups_path
    end
  end
end