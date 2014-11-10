# encoding: utf-8
require 'nokogiri'
class GrammarQuestionsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    @grammars = GrammarQuestion.order("created_at desc").page(params[:page])
  end

  def select_unit
    @unit = GrammarGroup.order("id asc")
  end

  def edit_title
    redirect_to select_unit_grammar_questions_path, notice: "请选着单元!" and return if params[:unit_id].blank?
  end

  def new
    redirect_to edit_title_grammar_questions_path(unit_id: params[:unit_id]), notice: "请输入句子!" and return if params[:title].blank?

  end

  def create
    b = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.assessmentItem 'xmlns'=>"http://www.imsglobal.org/xsd/imsqti_v2p1", 'xmlns:xsi'=>"http://www.w3.org/2001/XMLSchema-instance",
      'xsi:schemaLocation'=>"http://www.imsglobal.org/xsd/imsqti_v2p1  http://www.imsglobal.org/xsd/qti/qtiv2p1/imsqti_v2p1.xsd", 'identifier'=>"textEntry",
      'title'=>"#{params[:grammar_name]}", 'adaptive'=>"false", 'timeDependent'=>"false" do
        xml.responseDeclaration 'identifier'=>"RESPONSE", 'cardinality'=>"single", 'baseType'=>"string" do
          xml.correctResponse do
            xml.value "#{params[:composition]}"
          end
        end
        xml.itemBody do
          xml.p "#{params[:title]}"
          xml.textEntryInteraction 'responseIdentifier'=>'RESPONSE', 'expectedLength'=>'15'
        end
        xml.responseProcessing 'template'=>"http://www.imsglobal.org/question/qti_v2p1/rptemplates/map_response"
      end
    end
    count = GrammarQuestion.where(grammar_group_id: params[:unit_id]).count
    grammar = GrammarQuestion.new
    grammar.sequence_number = count + 1
    grammar.content = b.to_xml
    grammar.grammar_group_id = params[:unit_id]
    if grammar.save
      xml_file = File.new("#{Rails.root}/public/system/xml/syntax/#{grammar.id}.xml", 'wb')
      xml_file.puts b.to_xml #写入数据
      xml_file.close #关闭文件流
      render json: {result: 1}
    else
      render json: {result: 0}
    end
  end

  def destroy
    grammar = GrammarQuestion.find params[:id]
    if grammar.destroy
      system("rm public/system/xml/syntax/#{params[:id]}.xml")
    end
    redirect_to grammar_questions_path
  end
end