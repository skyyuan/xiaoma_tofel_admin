class VocabularyQuestion < ActiveRecord::Base
  belongs_to :vocabulary_group

  def parse_xml_to_object
    content_xml = Nokogiri::XML(content)
    questions = {}
    answer = content_xml.css('responseDeclaration')[0].search('correctResponse value')
    answer.each do |c|
      questions[:answer] = c.content
    end
    item_body = content_xml.css('itemBody')
    questions[:speech] = item_body.css('explanation').first.content
    questions[:prompt] = item_body.css('choiceInteraction prompt').first.content
    simple_choices = item_body.css('choiceInteraction')[0].search('simpleChoice')
    questions[:simple_choice_value ]= []
    questions[:simple_choice_identifier ]= []
    simple_choices.each_with_index do |simple_choice,index|
      questions[:simple_choice_identifier] << simple_choice.attribute('identifier').content
      questions[:simple_choice_value] << simple_choice.content
    end
    questions
  end

  def self.content_fromat_xml(params)
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

    b.to_xml
  end
end
