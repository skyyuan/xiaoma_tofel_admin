# encoding: utf-8
require 'nokogiri'
class GrammarQuestionsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    @grammars = GrammarQuestion.order("created_at desc").page(params[:page])
  end

  def select_unit
    @unit = GrammarGroup.order("sequence_number asc")
  end

  def edit_title
    redirect_to select_unit_grammar_questions_path, notice: "请选着单元!" and return if params[:unit_id].blank?
  end

  def new
    redirect_to edit_title_grammar_questions_path(unit_id: params[:unit_id]), notice: "请输入句子!" and return if params[:title].blank?

  end

  def create
    b = GrammarQuestion.content_fromat_xml(params)
    count = GrammarQuestion.where(grammar_group_id: params[:unit_id]).count
    grammar = GrammarQuestion.new
    grammar.sequence_number = count + 1
    grammar.content = b
    grammar.grammar_group_id = params[:unit_id]
    if grammar.save
      xml_file = File.new("#{Rails.root}/public/system/xml/syntax/#{grammar.id}.xml", 'wb')
      xml_file.puts b #写入数据
      xml_file.close #关闭文件流
      render json: {result: 1}
    else
      render json: {result: 0}
    end
  end

  def show
    @grammar_question = GrammarQuestion.find params[:id]
    @question_content = @grammar_question.parse_xml_to_object
  end

  def edit
    @grammar_question = GrammarQuestion.find params[:id]
    @question_content = @grammar_question.parse_xml_to_object
  end

  def update
    xml = GrammarQuestion.content_fromat_xml(params)
    @grammar_question = GrammarQuestion.find params[:id]
    @grammar_question.content = xml
    if @grammar_question.save
      File.open("#{Rails.root}/public/system/xml/syntax/#{@grammar_question.id}.xml", "wb") do |file|
        file.write xml
      end
    end
    redirect_to grammar_questions_path
  end

  def destroy
    grammar = GrammarQuestion.find params[:id]
    number = grammar.sequence_number
    group_id = grammar.grammar_group_id
    if grammar.destroy
      questions = GrammarQuestion.where("sequence_number > ? and grammar_group_id = ?", number, group_id)
      questions.each do |quesion|
        quesion.sequence_number = quesion.sequence_number.to_i - 1
        quesion.save
      end
      system("rm public/system/xml/syntax/#{params[:id]}.xml")
    end
    redirect_to grammar_questions_path
  end
end