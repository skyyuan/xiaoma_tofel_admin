# encoding: utf-8
# -*- encoding: utf-8 -*-
class VocabularyQuestionsController < ApplicationController

  def index
    @vocabularies = VocabularyQuestion.order("id desc").page(params[:page])
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
