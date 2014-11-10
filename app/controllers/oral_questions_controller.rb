# encoding: utf-8

class OralQuestionsController < ApplicationController
  def index
    @left_nav = 'oral_questions'
    @top_nav = 'list'
    session[:_tofel_oral_question] = nil
    session[:_tofel_oral_question_unit] = nil
    query_params = {}
    query_params.merge!(oral_group_id: params[:unit]) if params[:unit].present?
    @oral_questions = OralQuestion.joins(:oral_group).includes(:oral_group).where(query_params).order('CONVERT(oral_groups.sequence_number,SIGNED), CONVERT(oral_questions.sequence_number,SIGNED)').page(params[:page])
  end

  def choose_range
    @left_nav = 'oral_questions'
    relation = OralOrigin.where(name: 'tpo1').first.oral_groups.order('CONVERT(sequence_number,SIGNED)')
    @sources = relation.pluck(:name)
    @unit_for_selection = relation.map {|oral_group| [oral_group.sequence_number, oral_group.id]}
    session[:_tofel_oral_question_tpo] = nil
    session[:_tofel_oral_question_unit] = nil
  end

  def new
    @left_nav = 'oral_questions'
    session[:_tofel_oral_question_tpo] ||= params[:tpo]
    session[:_tofel_oral_question_unit] ||= params[:unit]
    if !OralOrigin.ids.include?(session[:_tofel_oral_question_tpo].to_i) || !OralGroup.ids.include?(session[:_tofel_oral_question_unit].to_i)
      redirect_to oral_questions_path and return
    end
    @unit = OralGroup.where(id: session[:_tofel_oral_question_unit]).first.sequence_number
    @oral_question = OralQuestion.new
  end

  def create
    @oral_question = OralQuestion.new(oral_question_params)
    @oral_question.oral_group_id = session[:_tofel_oral_question_unit]
    @oral_question.sequence_number = OralQuestion.where(oral_group_id: session[:_tofel_oral_question_unit]).count + 1
    if @oral_question.save
      redirect_to oral_question_path(@oral_question)
    end
  end

  def show
    @left_nav = 'oral_questions'
    @oral_question = OralQuestion.find(params[:id])
    @oral_question_amount = OralQuestion.where(oral_group_id: @oral_question.oral_group_id).count
  end

  def edit
    @left_nav = 'oral_questions'
    @oral_question = OralQuestion.find(params[:id])
  end

  def update
    @oral_question = OralQuestion.find(params[:id])
    if @oral_question.update_attributes(oral_question_params)
      redirect_to oral_question_path(@oral_question, from: params[:from])
    end
  end

  def destroy
    oral_question = OralQuestion.find(params[:id])
    oral_group_id = oral_question.oral_group_id
    sequence_number = oral_question.sequence_number
    OralQuestion.transaction do
      if oral_question.destroy
        OralQuestion.where('oral_group_id = ? and CONVERT(sequence_number,SIGNED) > ?', oral_group_id, sequence_number).each do |oral_question|
          oral_question.sequence_number = oral_question.sequence_number.to_i - 1
          oral_question.save
        end
      end
    end
    redirect_to oral_questions_path(unit: params[:unit])
  end

  def unit_list
    records = []
    oral_origin = OralOrigin.find(params[:tpo_id])
    records = oral_origin.oral_groups.order('CONVERT(sequence_number,SIGNED)').map{|item| {unit: item.sequence_number, id: item.id, source: item.name}}
    render json: records
  end

  private

  def oral_question_params
    params.require(:oral_question).permit(:data_url, :original_text)
  end
end
