# encoding: utf-8
require 'nokogiri'
class GrammarQuestionsController < ApplicationController
  def index

  end

  def new
    @unit = GrammarGroup.order("sequence_number asc")
  end

  def create
    b = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.assessmentItem 'xmlns'=>"http://www.imsglobal.org/xsd/imsqti_v2p1", 'xmlns:xsi'=>"http://www.w3.org/2001/XMLSchema-instance",
      'xsi:schemaLocation'=>"http://www.imsglobal.org/xsd/imsqti_v2p1  http://www.imsglobal.org/xsd/qti/qtiv2p1/imsqti_v2p1.xsd", 'identifier'=>"textEntry",
      'title'=>"#{param[:grammar_name]}", 'adaptive'=>"false", 'timeDependent'=>"false" do
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
    group = GrammarGroup.find_by_sequence_number(params[:number])
    count = GrammarQuestion.where(grammar_group_id: group.id).count
    grammar = GrammarQuestion.new
    grammar.sequence_number = count + 1
    grammar.content = b.to_xml
    grammar.grammar_group_id = group.id
    grammar.save
    xml_file = File.new("#{Rails.root}/public/system/xml/syntax/#{grammar.id}.xml", 'wb')
    xml_file.puts b.to_xml #写入数据
    xml_file.close #关闭文件流
    redirect_to grammar_questions_path
  end
end
