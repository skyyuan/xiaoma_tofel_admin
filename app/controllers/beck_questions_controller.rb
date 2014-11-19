# encoding: utf-8
class BeckQuestionsController < ApplicationController
  def index
    @questions = JijingQuestion.joins(:jijing_group).where("jijing_groups.group_type = 2")
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
    @questions = @questions.order("id desc").page(params[:page])
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

  def show
    @question = JijingQuestion.find(params[:id])
  end

  def edit
    @question = JijingQuestion.find(params[:id])
  end

  def update
    @question = JijingQuestion.find(params[:id])

    redirect_to beck_questions_path
  end

  def destroy
    @question = JijingQuestion.find(params[:id])
    @question.destroy
    redirect_to beck_questions_path
  end

  def delete
    @question = JijingQuestion.destroy_all
    redirect_to beck_questions_path
  end

end
