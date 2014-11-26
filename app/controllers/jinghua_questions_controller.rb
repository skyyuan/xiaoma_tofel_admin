# encoding: utf-8
class JinghuaQuestionsController < ApplicationController

  def index
    @questions = JinghuaQuestion.order("id desc").page(params[:page])
  end

  def new
  end

  def create
    if params[:upload].present?
      file = params[:upload]
      file_name = file.original_filename.split(".")
      if file_name.last == 'xls'
        File.open("#{Rails.root}/public/system/xls/#{file.original_filename}", "wb+") do |f|
          f.write(file.read)
        end
        Question.perform_async(file.original_filename)
        redirect_to jinghua_questions_path and return
      else
        redirect_to new_jinghua_question_path, notice: "请上传XLS格式文件!" and return
      end
    else
      redirect_to new_jinghua_question_path, notice: "请上传XLS格式文件!" and return
    end
  end
  def edit
    @jinghua_question = JinghuaQuestion.find params[:id]
  end

  def update
    @jinghua_question = JinghuaQuestion.find params[:id]
    @jinghua_question.update_attributes(params[:jinghua_question])
    redirect_to jinghua_questions_path
  end

  def destroy
    @jinghua_question = JinghuaQuestion.find params[:id]
    @jinghua_question.destroy
    redirect_to jinghua_questions_path
  end
end
