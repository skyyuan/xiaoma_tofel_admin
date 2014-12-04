# encoding: utf-8

class GrammarQuestion < ActiveRecord::Base
  belongs_to :grammar_group

  def parse_xml_to_object
    content_xml = Nokogiri::XML(content)
    questions = {}
    questions[:name] = content_xml.css('assessmentItem').attribute('title').content
    questions[:gc] = content_xml.css('responseDeclaration')[0].search('correctResponse value')[0].content
    item_body = content_xml.css('itemBody')
    questions[:jz] = item_body.css('p').first.content
    questions
  end

  def self.content_fromat_xml(params)
    b = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.assessmentItem 'xmlns'=>"http://www.imsglobal.org/xsd/imsqti_v2p1", 'xmlns:xsi'=>"http://www.w3.org/2001/XMLSchema-instance",
      'xsi:schemaLocation'=>"http://www.imsglobal.org/xsd/imsqti_v2p1  http://www.imsglobal.org/xsd/qti/qtiv2p1/imsqti_v2p1.xsd", 'identifier'=>"textEntry",
      'title'=>"#{params[:grammar_name]}", 'adaptive'=>"false", 'timeDependent'=>"false" do
        xml.responseDeclaration 'identifier'=>"RESPONSE", 'cardinality'=>"single", 'baseType'=>"string" do
          xml.correctResponse do
            composition = params[:composition]
            composition = composition.gsub('‘', "'").gsub('’', "'") if composition.present?
            xml.value composition
          end
        end
        xml.itemBody do
          title = params[:title]
          title = title.gsub('‘', "'").gsub('’', "'") if title.present?
          xml.p title
          xml.textEntryInteraction 'responseIdentifier'=>'RESPONSE', 'expectedLength'=>'15'
        end
        xml.responseProcessing 'template'=>"http://www.imsglobal.org/question/qti_v2p1/rptemplates/map_response"
      end
    end

    b.to_xml
  end
end
