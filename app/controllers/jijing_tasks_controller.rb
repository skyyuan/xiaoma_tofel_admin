class JijingTasksController < ApplicationController
  def new
  end

  def create
    if params[:id].present?
      task = JijingTask.find params[:id]
    else
      task = JijingTask.new
    end

    task.name = params[:task_name]
    task.jijing_group_id = params[:group_id]
    if task.save
      redirect_to new_jijing_question_path(number: params[:number],task_id: task.id)
    else
      redirect_to new_jijing_task_path(group_id: task.jijing_group_id)
    end
  end
end
