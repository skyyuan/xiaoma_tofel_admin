# encoding: utf-8

class DictationQuestionsController < ApplicationController

  def index
    @left_nav = 'dictation_questions'
    @top_nav = 'list'
    session[:_tofel_dictation_question] = nil
    query_params = {}
    query_params.merge!('dictation_groups.id' => params[:unit]) if params[:unit].present?
    @dictation_questions = DictationQuestion.joins(:dictation_group).includes(:dictation_group).where(query_params).order('dictation_groups.name, sequence_number').page(params[:page])
  end

  def choose_unit
    @left_nav = 'dictation_questions'
    session[:_tofel_dictation_question] = nil
  end

  def new
    @left_nav = 'dictation_questions'
    session[:_tofel_dictation_question] ||= params[:unit]
    redirect_to dictation_questions_path and return unless DictationGroup.ids.include?(session[:_tofel_dictation_question].to_i)
    @unit = DictationGroup.where(id: session[:_tofel_dictation_question]).first.name
    @dictation_question = DictationQuestion.new
  end

  def create
    @dictation_question = DictationQuestion.new(dictation_question_params)
    @dictation_question.dictation_group_id = session[:_tofel_dictation_question]
    @dictation_question.sequence_number = (DictationQuestion.where(dictation_group_id: session[:_tofel_dictation_question]).maximum('sequence_number') || 0) + 1
    sample = dictation_question_params[:sample]
    sample = sample.gsub('‘', "'").gsub('’', "'") if sample.present?
    @dictation_question.sample = sample
    if @dictation_question.save
      redirect_to dictation_question_path(@dictation_question)
    end
  end

  def show
    @left_nav = 'dictation_questions'
    @dictation_question = DictationQuestion.find(params[:id])
    @dictation_question_amount = DictationQuestion.where(dictation_group_id: @dictation_question.dictation_group_id).count
  end

  def edit
    #session[:_tofel_dictation_question] = nil
    @left_nav = 'dictation_questions'
    @dictation_question = DictationQuestion.find(params[:id])
  end

  def update
    @dictation_question = DictationQuestion.find(params[:id])

    sample = dictation_question_params[:sample]
    sample = sample.gsub('‘', "'").gsub('’', "'") if sample.present?
    if @dictation_question.update_attributes(sample.present? ? dictation_question_params.merge!(sample: sample) : dictation_question_params)
      redirect_to dictation_question_path(@dictation_question, from: params[:from])
    end
  end

  def destroy
    dictation_question = DictationQuestion.find(params[:id])
    dictation_group_id = dictation_question.dictation_group_id
    sequence_number = dictation_question.sequence_number
    DictationQuestion.transaction do
      if dictation_question.destroy
        DictationQuestion.where('dictation_group_id = ? and sequence_number > ? ', dictation_group_id, sequence_number).each do |dictation_question|
          dictation_question.decrement!(:sequence_number)
        end
      end
    end
    redirect_to dictation_questions_path(unit: params[:unit])
  end

  def add_group
    @top_nav = 'add_group'
    @left_nav = 'dictation_questions'
    @dictation_groups = DictationGroup.all.order('CONVERT(name,SIGNED)')
  end

  def create_group
    if DictationGroup.where(name: params[:name]).exists?
      alert = 'Unit已经存在'
    else
      DictationGroup.create(name: params[:name])
    end
    redirect_to add_group_dictation_questions_path, alert: alert

    # # 一次添加多个连续单元
    # if dictation_group_params =~ /^\d+-\d+$/
    #   start, finish = dictation_group_params.split('-')
    #   exists_group_names = DictationGroup.pluck(:name)
    #   # 结束必须大于开始，不能添加已存在的单元
    #   if finish > start && (exists_group_names - (start..finish).to_a == exists_group_names)
    #     (start..finish).each do |group_name|
    #       DictationGroup.create(name: group_name)
    #     end
    #   end
    # # 添加1个单元
    # elsif dictation_group_params[:units].persent? && !exists_group_names.include?(dictation_group_params[:units])
    #   DictationGroup.create(name: dictation_group_params[:units])
    # end
  end

  def delete_group
    dictation_group = DictationGroup.where(id: params[:id]).first
    dictation_group.destroy if dictation_group.present?
    redirect_to add_group_dictation_questions_path
  end

  private

  def dictation_question_params
    params.require(:dictation_question).permit(:audio_url, :sample)
  end

  # def dictation_group_params
  #   params.permit(:units)
  # end
end
