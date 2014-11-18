# encoding: utf-8
class TpoListensController < ApplicationController
  def index
    @left_nav = 'tpo_listens'
    @top_nav = 'list'
    session[:_tofel_tpo_listen_group] = nil
    session[:_tofel_tpo_listen_type] = nil

    @tpo_questions = TpoQuestion.includes(:tpo_type).joins(tpo_type: :tpo_group).where(tpo_types: {name: ['Conversion', 'Lecture']}).order(:sequence_number).page(params[:page])
  end

  def choose_range
    @left_nav = 'tpo_listens'
    session[:_tofel_tpo_listen_group] = nil
    session[:_tofel_tpo_listen_type] = nil
  end

  def new
    @left_nav = 'tpo_listens'
    session[:_tofel_tpo_listen_group] ||= params[:tpo_group]
    session[:_tofel_tpo_listen_type] ||= params[:tpo_type]
    if !TpoGroup.ids.include?(session[:_tofel_tpo_listen_group].to_i) || !TpoType::LISTEN_TYPE.keys.include?(session[:_tofel_tpo_listen_type].to_i)
      redirect_to tpo_listens_path and return
    end
    @tpo_group_name = TpoGroup.where(id: session[:_tofel_tpo_listen_group]).first.name
  end

  def change_question_type
    if params[:type] == 'add_question'
      render :partial => 'simple_choice', locals: { num: params[:current_question_num].to_i + 1 }
    elsif params[:type] == 'change_question'
      case params[:change_question_type_to]
      when '1'
        _partial = 'simple_choice'
      when '2'
        _partial = 'multiple_choice'
      end

      if params[:question_id].present?
        tpo_question = TpoQuestion.find(params[:question_id])
        tpo_question_content = tpo_question.parse_xml_to_object
        change_type = 'edit'
      end
      render :partial => _partial, locals: { num: params[:current_question_num], tpo_question_content: tpo_question_content, change_type: change_type }
    end
  end

  def create
    listen_type = TpoType::LISTEN_TYPE[session[:_tofel_tpo_listen_type].to_i]
    tpo_type_name = listen_type[0..-2]
    sequence_number = listen_type[-1]
    tpo_type = TpoType.where(tpo_group_id: session[:_tofel_tpo_listen_group], name: tpo_type_name).first
    unless tpo_type
      tpo_type = TpoType.new
      tpo_type.name = tpo_type_name
      tpo_type.tpo_group_id = session[:_tofel_tpo_listen_group]
      tpo_type.save
    end

    tpo_question = TpoQuestion.new
    tpo_question.tpo_type_id = tpo_type.id
    # 因为type分为 Conversion与Lecture1
    tpo_type_ids = TpoType.where(tpo_group_id: session[:_tofel_tpo_listen_group]).ids
    tpo_question.sequence_number = sequence_number
    content = TpoQuestion.listen_content_fromat_xml(params, tpo_type_name)
    tpo_question.content = content
    if tpo_question.save
      File.open("#{Rails.root}/public/system/xml/tpo/listens/#{tpo_question.id}.xml", "wb") do |file|
        file.write content
      end
    end
    redirect_to tpo_listen_path(tpo_question)
  end

  def show
    @left_nav = 'tpo_listens'
    @tpo_question = TpoQuestion.find(params[:id])
    @tpo_type = @tpo_question.tpo_type
    @tpo_group = @tpo_type.tpo_group
    @tpo_question_content = @tpo_question.parse_listen_xml_to_object
  end

  def edit
    @left_nav = 'tpo_listens'
    @from = 'edit'
    @tpo_question = TpoQuestion.find(params[:id])
    tpo_type = @tpo_question.tpo_type
    @tpo_type_name = tpo_type.name
    @tpo_group = tpo_type.tpo_group
    @tpo_group_name = @tpo_group.name
    @tpo_question_content = @tpo_question.parse_listen_xml_to_object
  end

  def update
    tpo_question = TpoQuestion.find(params[:id])
    tpo_type_name = tpo_question.tpo_type.name
    content = TpoQuestion.listen_content_fromat_xml(params, tpo_type_name)
    tpo_question.content = content
    if tpo_question.save
      File.open("#{Rails.root}/public/system/xml/tpo/listens/#{tpo_question.id}.xml", "wb") do |file|
        file.write content
      end
    end
    redirect_to tpo_listen_path(tpo_question, from: params[:from])
  end

  def destroy
    tpo_question = TpoQuestion.find(params[:id])
    tpo_type_id = tpo_question.tpo_type.id
    sequence_number = tpo_question.sequence_number
    TpoQuestion.transaction do
      if tpo_question.destroy
        TpoQuestion.where('tpo_type_id = ? and sequence_number > ?', tpo_type_id, sequence_number).each do |tpo_question|
          tpo_question.decrement!(:sequence_number)
        end
      end
    end
    redirect_to tpo_listens_path
  end

  def upload_file
    @top_nav = 'upload_file'
  end

  def batch_import
    if params[:tpo_listen_file].present?
      listen_file = params[:tpo_listen_file]
      if listen_file.original_filename.split(".").last == 'xls'
        TpoQuestion.listen_batch_import(listen_file)
      else
        redirect_to upload_file_tpo_listens_path, alert: "请上传XLS格式文件!" and return
      end
    end
    redirect_to tpo_listens_path
  end
end
