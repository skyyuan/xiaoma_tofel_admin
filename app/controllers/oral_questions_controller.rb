# encoding: utf-8

class OralQuestionsController < ApplicationController
  def index
    @left_nav = 'oral_questions'
    @top_nav = 'list'
    session[:_tofel_oral_question] = nil
    session[:_tofel_oral_question_unit] = nil
    query_params = {}
    # query_params.merge!(oral_group_id: params[:unit]) if params[:unit].present?
    # @oral_questions = OralQuestion.joins(:oral_group).includes(:oral_group).where(query_params).order('CONVERT(oral_groups.sequence_number,SIGNED), CONVERT(oral_questions.sequence_number,SIGNED)').page(params[:page])

    query_params.merge!(id: params[:unit]) if params[:unit].present?
    @oral_groups = OralGroup.includes(:oral_questions).joins(:oral_questions).where(query_params).order('CONVERT(oral_groups.sequence_number,SIGNED)').uniq.page(params[:page])
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
    data_url = oral_question_params[:oral_question][:data_url]
    show_oral_question = nil
    OralQuestion.transaction do
      oral_question_params[:original_text].each_with_index do |original_text, idx|
        oral_question = OralQuestion.new(data_url: data_url, original_text: original_text)
        oral_question.oral_group_id = session[:_tofel_oral_question_unit]
        oral_question.sequence_number = OralQuestion.where(oral_group_id: session[:_tofel_oral_question_unit]).count + 1
        oral_question.save
        show_oral_question = oral_question if idx.zero?
      end
    end
    redirect_to oral_question_path(show_oral_question)
  end

  def next_unit
    n_unit = params[:current_unit].to_i + 1
    # temporary
    if n_unit < 199
      oral_group = OralGroup.where(sequence_number: n_unit).first
      session[:_tofel_oral_question_unit] = oral_group.id
      session[:_tofel_oral_question_tpo] = oral_group.oral_origin.try(:id)
    else
      session[:_tofel_oral_question_unit] = nil
      session[:_tofel_oral_question_tpo] = nil
    end
    redirect_to new_oral_question_path
  end

  def show
    @left_nav = 'oral_questions'
    @first_oral_question = OralQuestion.find(params[:id])
    @oral_questions = OralQuestion.where(oral_group_id: @first_oral_question.oral_group_id)
  end

  def edit
    @left_nav = 'oral_questions'
    @from = 'edit'
    @first_oral_question = OralQuestion.find(params[:id])
    @oral_questions = OralQuestion.where(oral_group_id: @first_oral_question.oral_group_id)
  end

  def update
    data_url = oral_question_params[:oral_question][:data_url]
    update_oral_question = nil
    oral_group_id = OralQuestion.find(params[:id]).oral_group_id
    OralQuestion.transaction do
      OralQuestion.where(oral_group_id: oral_group_id).delete_all
      oral_question_params[:original_text].each_with_index do |original_text, idx|
        oral_question = OralQuestion.new(data_url: data_url, original_text: original_text)
        oral_question.oral_group_id = oral_group_id
        oral_question.sequence_number = OralQuestion.where(oral_group_id: oral_group_id).count + 1
        oral_question.save
        update_oral_question = oral_question if idx.zero?
      end
    end
    redirect_to oral_question_path(update_oral_question, from: params[:from])

    # @oral_question = OralQuestion.find(params[:id])
    # if @oral_question.update_attributes(oral_question_params)
    #   redirect_to oral_question_path(@oral_question, from: params[:from])
    # end
  end

  def destroy
    oral_question = OralQuestion.find(params[:id])
    oral_group_id = oral_question.oral_group_id
    OralQuestion.where(oral_group_id: oral_group_id).delete_all
    # sequence_number = oral_question.sequence_number
    # OralQuestion.transaction do
    #   if oral_question.destroy
    #     OralQuestion.where('oral_group_id = ? and CONVERT(sequence_number,SIGNED) > ?', oral_group_id, sequence_number).each do |oral_question|
    #       oral_question.sequence_number = oral_question.sequence_number.to_i - 1
    #       oral_question.save
    #     end
    #   end
    # end
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
    # params.require(:oral_question).permit(:data_url, original_text: [])
    params.permit({original_text: []}, oral_question: [:data_url])
  end
end
