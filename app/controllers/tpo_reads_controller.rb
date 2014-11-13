# encoding: utf-8

class TpoReadsController < ApplicationController
  def index
    @left_nav = 'tpo_reads'
    @top_nav = 'list'
    session[:_tofel_tpo_read_group] = nil
    session[:_tofel_tpo_read_type] = nil
    query_params = {}

    @tpo_questions = TpoQuestion.includes(:tpo_type, :tpo_group).joins(tpo_type: :tpo_group).where(tpo_types: {name: 'Passage'}).order(:sequence_number).page(params[:page])
  end

  def choose_range
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
      render :partial => _partial, locals: { num: params[:current_question_num] }
    end
  end

  def create
    tpo_type = TpoType.where(tpo_group_id: session[:_tofel_tpo_read_group]).first
    unless tpo_type
      tpo_type = TpoType.new
      tpo_type.name = 'Passage'
      tpo_type.tpo_group_id = session[:_tofel_tpo_read_group]
      tpo_type.save
    end

    tpo_question = TpoQuestion.new
    tpo_question.tpo_type_id = tpo_type.id
    tpo_question.sequence_number = TpoQuestion.joins(:tpo_type).where(:tpo_type_id => tpo_type.id, 'tpo_types.tpo_group_id' => session[:_tofel_tpo_read_group]).count + 1
    content = TpoQuestion.read_content_fromat_xml(params)
    tpo_question.content = content
    if tpo_question.save
      Dir.mkdir("#{Rails.root}/public/system") unless Dir.exist?("#{Rails.root}/public/system")
      Dir.mkdir("#{Rails.root}/public/system/xml") unless Dir.exist?("#{Rails.root}/public/system/xml")
      Dir.mkdir("#{Rails.root}/public/system/xml/tpo") unless Dir.exist?("#{Rails.root}/public/system/xml/tpo")
      Dir.mkdir("#{Rails.root}/public/system/xml/tpo/reads") unless Dir.exist?("#{Rails.root}/public/system/xml/tpo/reads")
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
    @tpo_question_content = @tpo_question.parse_xml_to_object
  end

  def edit
    @left_nav = 'tpo_reads'
    @from = 'edit'
    @first_oral_question = OralQuestion.find(params[:id])
    @oral_questions = OralQuestion.where(oral_group_id: @first_oral_question.oral_group_id)
  end

  def update
    data_url = oral_question_params[:oral_question][:data_url]
    update_oral_question = nil
    oral_group_id = OralQuestion.find(params[:id]).oral_group_id
    OralQuestion.transaction do
      OralQuestion.where(oral_group_id: oral_group_id).delete_all
      oral_question_params[:original_text].each_with_index do |original_text, idx|
        oral_question = OralQuestion.new(data_url: data_url, original_text: original_text)
        oral_question.oral_group_id = oral_group_id
        oral_question.sequence_number = OralQuestion.where(oral_group_id: oral_group_id).count + 1
        oral_question.save
        update_oral_question = oral_question if idx.zero?
      end
    end
    redirect_to oral_question_path(update_oral_question, from: params[:from])

    # @oral_question = OralQuestion.find(params[:id])
    # if @oral_question.update_attributes(oral_question_params)
    #   redirect_to oral_question_path(@oral_question, from: params[:from])
    # end
  end

  def destroy
    oral_question = OralQuestion.find(params[:id])
    oral_group_id = oral_question.oral_group_id
    OralQuestion.where(oral_group_id: oral_group_id).delete_all
    # sequence_number = oral_question.sequence_number
    # OralQuestion.transaction do
    #   if oral_question.destroy
    #     OralQuestion.where('oral_group_id = ? and CONVERT(sequence_number,SIGNED) > ?', oral_group_id, sequence_number).each do |oral_question|
    #       oral_question.sequence_number = oral_question.sequence_number.to_i - 1
    #       oral_question.save
    #     end
    #   end
    # end
    redirect_to oral_questions_path(unit: params[:unit])
  end

  def unit_list
    records = []
    oral_origin = OralOrigin.find(params[:tpo_id])
    records = oral_origin.oral_groups.order('CONVERT(sequence_number,SIGNED)').map{|item| {unit: item.sequence_number, id: item.id, source: item.name}}
    render json: records
  end

  private

  def tpo_read_params
    # params.require(:oral_question).permit(:data_url, original_text: [])
    # params.permit({original_text: []}, oral_question: [:data_url])
    params.permit(:title)
  end
end