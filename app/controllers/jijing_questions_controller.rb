# encoding: utf-8
class JijingQuestionsController < ApplicationController
  def index
    @questions = JijingQuestion.order("created_at desc").page(params[:page]).per(10)
  end

  def new
    @task = JijingTask.find(params[:task_id])
  end

  def create
    if params[:question_name].present?
      question = JijingQuestion.new
      question.sequence_number = params[:number]
      question.jijing_task_id = params[:task_id]
      question.content = params[:question_name]
      question.analysis = params[:question_analysis]
      if question.save
        samp = JijingSample.new
        samp.content = params[:sample_name]
        samp.user_id = 1
        samp.jijing_question_id = question.id
        samp.save
        redirect_to jijing_questions_path
      else
        redirect_to new_jijing_question_path(number: params[:number],task_id: params[:task_id]), notice: "保存失败!"
      end
    else
      redirect_to new_jijing_question_path(number: params[:number],task_id: params[:task_id]), notice: "题目不能为空!"
    end
  end
end
