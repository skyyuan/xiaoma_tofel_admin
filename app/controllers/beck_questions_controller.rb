# encoding: utf-8
class BeckQuestionsController < ApplicationController
  def index
    @questions = JijingQuestion.joins(:jijing_group).where("jijing_groups.group_type = 2")
    if params[:data].present?
      @questions = @questions.where("jijing_groups.name like ?", "%#{params[:data]}%")
    end
    if params[:type].present?
      type = nil
      if params[:type] == '口语'
        type = 1
      end
      if params[:type] == '写作'
        type = 2
      end
      @questions = @questions.where(question_type: type)
    end
    if params[:content].present?
      @questions = @questions.where("jijing_questions.content like ?", "%#{params[:content]}%")
    end
    @questions = @questions.order("created_at desc").page(params[:page])
  end

  def create
    if params[:upload].present?
      file = params[:upload]
      file_name = file.original_filename.split(".")
      if file_name.last == 'xls'
        File.open("#{Rails.root}/public/system/xls/#{file.original_filename}", "wb+") do |f|
          f.write(file.read)
        end
        Jijing.perform_async(file.original_filename)
        redirect_to beck_questions_path and return
      else
        redirect_to beck_questions_path, notice: "请上传XLS格式文件!" and return
      end
    else
      redirect_to beck_questions_path, notice: "请上传XLS格式文件!" and return
    end
  end

  def edit
    @question = JijingQuestion.find(params[:id])
  end

  def update
    @question = JijingQuestion.find(params[:id])
    @question.sequence_number = params[:sequence_number]
    @question.content = params[:content]
    @question.analysis = params[:analysis]
    if @question.save
      if params[:sample_name].present?
        if @question.jijing_sample.present?
          @question.jijing_sample.content = params[:sample_name]
          @question.jijing_sample.save
        else
          sample = JijingSample.new
          sample.content = params[:sample_name]
          sample.jijing_question_id = @question.id
          sample.user_id = 1
          sample.save
        end
      end
    end
    redirect_to beck_questions_path
  end

  def destroy
    @question = JijingQuestion.find(params[:id])
    @question.destroy
    redirect_to beck_questions_path
  end

  def delete
    @question = JijingQuestion.joins(:jijing_group).where("jijing_groups.group_type = 2").destroy_all
    redirect_to beck_questions_path
  end

end
