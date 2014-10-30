#encoding =>utf-8
require 'nokogiri'

class GenerateXmlsController < ApplicationController

  layout 'admin'

  def index

  end

  def create
    b = Nokogiri::XML::Builder.new do |xml|
      #选项题
      #if params[:type] == 'radio'
        xml.assessmentItem 'xmlns'=>"http://www.imsglobal.org/xsd/imsqti_v2p1", 'xmlns:xsi'=>"http://www.w3.org/2001/XMLSchema-instance",
        'xsi:schemaLocation'=>"http://www.imsglobal.org/xsd/imsqti_v2p1  http://www.imsglobal.org/xsd/qti/qtiv2p1/imsqti_v2p1.xsd", 'identifier'=>"choice",
        'title'=>"Unattended Luggage", 'adaptive'=>"false", 'timeDependent'=>"false" do
          xml.responseDeclaration 'identifier'=>"RESPONSE", 'cardinality'=>"single", 'baseType'=>"identifier" do
            xml.correctResponse do
              xml.value "ChoiceA"
            end
          end
          xml.outcomeDeclaration 'identifier'=>"SCORE", 'cardinality'=>"single", 'baseType'=>"float" do
            xml.defaultValue do
              xml.value "0"
            end
          end
          xml.itemBody do
            xml.p "这是选择题！"
            xml.p "文章？"
            xml.choiceInteraction 'responseIdentifier'=>"RESPONSE", 'shuffle'=>"false", 'maxChoices'=>"1" do
              xml.prompt "这里是问题？"
              xml.simpleChoice '选项1', 'identifier'=>"ChoiceA"
              xml.simpleChoice '选项2','identifier'=>"ChoiceB"
              xml.simpleChoice '选项3','identifier'=>"ChoiceC"
            end
          end
          xml.responseProcessing 'template'=>"http://www.imsglobal.org/question/qti_v2p1/rptemplates/match_correct"
        end
      #end
      #填空题
      if params[:type] == 'text_entry'
        xml.assessmentItem 'xmlns'=>"http://www.imsglobal.org/xsd/imsqti_v2p1", 'xmlns:xsi'=>"http://www.w3.org/2001/XMLSchema-instance", 'xsi:schemaLocation'=>"http://www.imsglobal.org/xsd/imsqti_v2p1 http://www.imsglobal.org/xsd/qti/qtiv2p1/imsqti_v2p1.xsd", 'identifier'=>"textEntry", 'title'=>"Richard III (Take 3)", 'adaptive'=>"false", 'timeDependent'=>"false" do
          xml.responseDeclaration 'identifier'=>"RESPONSE", 'cardinality'=>"single", 'baseType'=>"string" do
            xml.correctResponse do
              xml.value "York"
            end
            xml.mapping 'defaultValue'=>"0" do
              xml.mapEntry 'mapKey'=>"York", 'mappedValue'=>"1"
              xml.mapEntry 'mapKey'=>"york", 'mappedValue'=>"0.5"
            end
          end
          xml.outcomeDeclaration 'identifier'=>"SCORE", 'cardinality'=>"single", 'baseType'=>"float"
          xml.itemBody do
            xml.p "填空题。"
            xml.blockquote do
              xml.p "这里是问题？" do
                xml.textEntryInteraction 'responseIdentifier'=>"RESPONSE", 'expectedLength'=>"15"
              end
            end
          end
          xml.responseProcessing 'template'=>"http://www.imsglobal.org/question/qti_v2p1/rptemplates/map_response"
        end
      end
      #写做题
      if params[:type] == 'extended_text'
        xml.assessmentItem 'xmlns'=>"http://www.imsglobal.org/xsd/imsqti_v2p1", 'xmlns:xsi'=>"http://www.w3.org/2001/XMLSchema-instance", 'xsi:schemaLocation'=>"http://www.imsglobal.org/xsd/imsqti_v2p1 http://www.imsglobal.org/xsd/qti/qtiv2p1/imsqti_v2p1.xsd", 'identifier'=>"extendedText", 'title'=>"Writing a Postcard", 'adaptive'=>"false", 'timeDependent'=>"false" do
          xml.responseDeclaration 'identifier'=>"RESPONSE", 'cardinality'=>"single", 'baseType'=>"string"
          xml.outcomeDeclaration 'identifier'=>"SCORE", 'cardinality'=>"single", 'baseType'=>"float"
          xml.itemBody do
            xml.p "写作题."
            xml.div do
              xml.blockquote 'class'=>"postcard" do
                xml.p "Here is a postcard of my town. Please send me"
              end
            end
            xml.extendedTextInteraction 'responseIdentifier'=>"RESPONSE", 'expectedLength'=>"200" do
              xml.prompt
            end
          end
        end
      end
    end
    file = File.new("#{Rails.root}/public/system/xml/xml.#{Time.now}", 'wb') #{ |f| f.write(b.to_xml) }
    file.puts b.to_xml #写入数据
    file.close #关闭文件流
  end
end
