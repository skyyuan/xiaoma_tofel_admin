# encoding: utf-8
class BeckQuestionsController < ApplicationController
  def index
    @vocabularies = JijingQuestion.order("id desc").page(params[:page])
  end

  def show
    @question = JijingQuestion.find(params[:id])
    @question_content = @question.parse_xml_to_object
  end

  def edit
    @question = JijingQuestion.find(params[:id])
    @question_content = @question.parse_xml_to_object
  end

  def update
    @question = JijingQuestion.find(params[:id])
    xml_content = JijingQuestion.content_fromat_xml(params)
    @question.word = params[:word]
    @question.content = xml_content
    if @question.save
      File.open("#{Rails.root}/public/system/xml/word/#{@question.word}.xml", "wb") do |file|
        file.write xml_content
      end
      system("rm public/system/xml/word/#{params[:before_word]}.xml")
    end
    redirect_to vocabulary_questions_path
  end

  def destroy
    @question = JijingQuestion.find(params[:id])
    word = @question.word
    if @question.destroy
      system("rm public/system/xml/word/#{word}.xml")
    end
    redirect_to vocabulary_questions_path
  end

  def delete
    @question = JijingQuestion.destroy_all
    redirect_to vocabulary_questions_path
  end

  def upload_vocabulary
    if params[:upload].present?
      file = params[:upload]
      file_name = file.original_filename.split(".")
      if file_name.last == 'xls'
        File.open("#{Rails.root}/public/system/xls/#{file.original_filename}", "wb+") do |f|
          f.write(file.read)
        end
        HardWorker.perform_async(file.original_filename)
        redirect_to vocabulary_questions_path and return
      else
        redirect_to index_upload_vocabulary_questions_path, notice: "请上传XLS格式文件!" and return
      end
    else
      redirect_to index_upload_vocabulary_questions_path, notice: "请上传XLS格式文件!" and return
    end
  end
end
