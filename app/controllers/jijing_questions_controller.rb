# encoding: utf-8
class JijingQuestionsController < ApplicationController
  def index
    @questions = JijingQuestion.joins(:jijing_group).where("jijing_groups.group_type = 1").where(question_type: 1).order("created_at desc").page(params[:page])
  end

  def new
  end

  def create
    if params[:question_name].present? && params[:number].present?
      is_number = JijingQuestion.where(question_type: 1,sequence_number: params[:number],jijing_group_id: params[:group_id])
      if !is_number.present?
        question = JijingQuestion.new
        question.sequence_number = params[:number]
        question.jijing_group_id = params[:group_id]
        question.content = params[:question_name]
        question.analysis = params[:question_analysis]
        question.question_type = 1
        if question.save
          if params[:sample_name].present?
            samp = JijingSample.new
            samp.content = params[:sample_name]
            samp.user_id = 1
            samp.jijing_question_id = question.id
            samp.save
          end
          redirect_to jijing_questions_path
        else
          redirect_to new_jijing_question_path(group_id: params[:group_id]), notice: "保存失败!"
        end
      else
        redirect_to new_jijing_question_path(group_id: params[:group_id]), notice: "该题号已存在!"
      end
    else
      redirect_to new_jijing_question_path(group_id: params[:group_id]), notice: "题目、题号不能为空!"
    end
  end

  def edit
    @jijing_quesion = JijingQuestion.find params[:id]
  end

  def update
    @jijing_quesion = JijingQuestion.find params[:id]
    if @jijing_quesion.update_attributes(params[:jijing_question])
      if params[:sample_name].present?
        if @jijing_quesion.jijing_sample.present?
          @jijing_quesion.jijing_sample.update_attributes(content: params[:sample_name])
        else
          samp = JijingSample.new
          samp.content = params[:sample_name]
          samp.user_id = 1
          samp.jijing_question_id = @jijing_quesion.id
          samp.save
        end
      end
    end
    if @jijing_quesion.question_type.to_i == 2
      redirect_to jijing_works_path
    else
      redirect_to jijing_questions_path
    end
  end

  def destroy
    @jijing_quesion = JijingQuestion.find params[:id]
    @jijing_quesion.destroy
    if @jijing_quesion.question_type.to_i == 2
      redirect_to jijing_works_path
    else
      redirect_to jijing_questions_path
    end
  end
end
