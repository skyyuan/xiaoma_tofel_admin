# encoding: utf-8
# -*- encoding: utf-8 -*-
class VocabularyQuestionsController < ApplicationController

  def index
    if params[:word].present?
      @vocabularies = VocabularyQuestion.where(word: params[:word]).order("id desc").page(params[:page])
    else
      @vocabularies = VocabularyQuestion.order("id desc").page(params[:page])
    end
  end

  def unit
    @groups = VocabularyGroup.order("(sequence_number + 0) asc")
  end

  def show
    @question = VocabularyQuestion.find(params[:id])
    @question_content = @question.parse_xml_to_object
  end

  def edit
    @question = VocabularyQuestion.find(params[:id])
    @question_content = @question.parse_xml_to_object
  end

  def update
    @question = VocabularyQuestion.find(params[:id])
    xml_content = VocabularyQuestion.content_fromat_xml(params)
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
    @question = VocabularyQuestion.find(params[:id])
    word = @question.word
    if @question.destroy
      system("rm public/system/xml/word/#{word}.xml")
    end
    redirect_to vocabulary_questions_path
  end

  def delete
    @question = VocabularyQuestion.destroy_all
    system("rm public/system/xml/word/*.xml")
    redirect_to vocabulary_questions_path
  end

  def index_upload

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
