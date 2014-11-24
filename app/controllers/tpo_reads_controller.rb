# encoding: utf-8

class TpoReadsController < ApplicationController
  def index
    @left_nav = 'tpo_reads'
    @top_nav = 'list'
    session[:_tofel_tpo_read_group] = nil
    session[:_tofel_tpo_read_type] = nil
    query_params = {}

    @tpo_questions = TpoQuestion.includes(:tpo_type).joins(tpo_type: :tpo_group).where(tpo_types: {name: 'passage'}).order(:sequence_number).page(params[:page])
  end

  def choose_range
    redirect_to add_tpo_tpo_reads_path and return unless TpoGroup.where(true).exists?
    @left_nav = 'tpo_reads'
    session[:_tofel_tpo_read_group] = nil
    session[:_tofel_tpo_read_type] = nil
  end

  def new
    @left_nav = 'tpo_reads'
    session[:_tofel_tpo_read_group] ||= params[:tpo_group]
    session[:_tofel_tpo_read_type] ||= params[:tpo_type]
    if !TpoGroup.ids.include?(session[:_tofel_tpo_read_group].to_i) || !TpoType::READ_TYPE.keys.include?(session[:_tofel_tpo_read_type].to_i)
      redirect_to tpo_reads_path and return
    end
    @tpo_group_name = TpoGroup.where(id: session[:_tofel_tpo_read_group]).first.name
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
      when '3'
        _partial = 'gap_match_interaction'
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
    tpo_type = TpoType.where(tpo_group_id: session[:_tofel_tpo_read_group], name: 'passage').first
    unless tpo_type
      tpo_type = TpoType.new
      tpo_type.name = 'passage'
      tpo_type.tpo_group_id = session[:_tofel_tpo_read_group]
      tpo_type.save
    end

    tpo_question = TpoQuestion.new
    tpo_question.tpo_type_id = tpo_type.id
    tpo_question.sequence_number = session[:_tofel_tpo_read_type]
    content = TpoQuestion.read_content_fromat_xml(params)
    tpo_question.content = content
    if tpo_question.save
      # Dir.mkdir("#{Rails.root}/public/system") unless Dir.exist?("#{Rails.root}/public/system")
      # Dir.mkdir("#{Rails.root}/public/system/xml") unless Dir.exist?("#{Rails.root}/public/system/xml")
      # Dir.mkdir("#{Rails.root}/public/system/xml/tpo") unless Dir.exist?("#{Rails.root}/public/system/xml/tpo")
      # Dir.mkdir("#{Rails.root}/public/system/xml/tpo/reads") unless Dir.exist?("#{Rails.root}/public/system/xml/tpo/reads")
      File.open("#{Rails.root}/public/system/xml/tpo/reads/#{tpo_question.id}.xml", "wb") do |file|
        file.write content
      end
    end
    redirect_to tpo_read_path(tpo_question)
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
    @left_nav = 'tpo_reads'
    @tpo_question = TpoQuestion.find(params[:id])
    @tpo_group = @tpo_question.tpo_type.tpo_group
    @tpo_question_content = @tpo_question.parse_xml_to_object
  end

  def edit
    @left_nav = 'tpo_reads'
    @from = 'edit'
    @tpo_question = TpoQuestion.find(params[:id])
    @tpo_group = @tpo_question.tpo_type.tpo_group
    @tpo_group_name = @tpo_group.name
    @tpo_question_content = @tpo_question.parse_xml_to_object
  end

  def update
    tpo_question = TpoQuestion.find(params[:id])
    content = TpoQuestion.read_content_fromat_xml(params)
    tpo_question.content = content
    if tpo_question.save
      File.open("#{Rails.root}/public/system/xml/tpo/reads/#{tpo_question.id}.xml", "wb") do |file|
        file.write content
      end
    end
    redirect_to tpo_read_path(tpo_question, from: params[:from])
  end

  def destroy
    TpoQuestion.find(params[:id]).destroy
    redirect_to tpo_reads_path
  end

  def upload_file
    @left_nav = 'tpo_reads'
    @top_nav = 'upload_file'
  end

  def batch_import
    if params[:tpo_read_file].present?
      read_file = params[:tpo_read_file]
      if read_file.original_filename.split(".").last == 'xls'
        # File.open("#{Rails.root}/public/system/xls/#{read_file.original_filename}", "wb+") do |f|
        #   f.write(read_file.read)
        # end
        # TpoQuestion.read_batch_import(read_file)
        File.open("#{Rails.root}/public/system/xls/#{read_file.original_filename}", "wb+") do |f|
          f.write(read_file.read)
        end
        TpoReadQuestionWorker.perform_async(read_file.original_filename)
      else
        redirect_to upload_file_tpo_reads_path, alert: "请上传XLS格式文件!" and return
      end
    end
    redirect_to tpo_reads_path
  end

  def add_tpo
    @top_nav = 'add_tpo'
    @left_nav = 'tpo_reads'
    @tpo_groups = TpoGroup.all
  end

  def create_tpo
    if TpoGroup.where(name: params[:name]).exists?
      alert = 'tpo已经存在'
    else
      TpoGroup.create(name: params[:name])
    end
    redirect_to add_tpo_tpo_reads_path, alert: alert
  end

  private

  def tpo_read_params
    # params.require(:oral_question).permit(:data_url, original_text: [])
    # params.permit({original_text: []}, oral_question: [:data_url])
    params.permit(:title)
  end
end
