# encoding: utf-8

class ReproductionQuestionsController < ApplicationController
  def index
    @left_nav = 'reproduction_questions'
    @top_nav = 'list'
    @reproduction_questions = ReproductionQuestion.where(true).order('CONVERT(sequence_number,SIGNED)').page(params[:page])
  end

  def new
    @left_nav = 'reproduction_questions'
    @reproduction_question = ReproductionQuestion.new
  end

  def create
    @reproduction_question = ReproductionQuestion.new(reproduction_question_params[:reproduction_question])
    @reproduction_question.sequence_number = ReproductionQuestion.count.to_i + 1
    ReproductionQuestion.transaction do
      # save reproduction question
      @reproduction_question.save
      # save reproduction sample
      reproduction_question_params[:en].each_with_index do |en, idx|
        ReproductionSample.create(reproduction_question_id: @reproduction_question.id, en: en, ch: reproduction_question_params[:ch][idx])
      end
    end
    redirect_to reproduction_question_path(@reproduction_question)
  end

  def show
    @left_nav = 'reproduction_questions'
    @reproduction_question = ReproductionQuestion.includes(:reproduction_samples).where(id: params[:id]).first
    @reproduction_question_amount = ReproductionQuestion.count
  end

  def edit
    @left_nav = 'reproduction_questions'
    @from = 'edit'
    @reproduction_question = ReproductionQuestion.find(params[:id])
  end

  def update
    reproduction_question = ReproductionQuestion.find(params[:id])
    ReproductionQuestion.transaction do
      # save reproduction question
      reproduction_question.update_attributes(reproduction_question_params[:reproduction_question])
      # save reproduction sample
      reproduction_question.reproduction_samples.delete_all
      reproduction_question_params[:en].each_with_index do |en, idx|
        ReproductionSample.create(reproduction_question_id: reproduction_question.id, en: en, ch: reproduction_question_params[:ch][idx])
      end
    end
    redirect_to reproduction_question_path(reproduction_question, from: params[:from])
  end

  def destroy
    reproduction_question = ReproductionQuestion.find(params[:id])
    sequence_number = reproduction_question.sequence_number
    ReproductionQuestion.transaction do
      if reproduction_question.destroy
        ReproductionQuestion.where('CONVERT(sequence_number,SIGNED) > ? ', sequence_number).each do |reproduction_question|
          reproduction_question.sequence_number = reproduction_question.sequence_number.to_i - 1
          reproduction_question.save
        end
      end
    end
    redirect_to reproduction_questions_path
  end

  private

  def reproduction_question_params
    params.permit({en: []}, {ch: []}, reproduction_question: [:content])
  end
end
