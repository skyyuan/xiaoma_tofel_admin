# encoding: utf-8
class TpoSpokensController < ApplicationController
  def index
    @questions = TpoQuestion.order("created_at desc").page(params[:page])
  end

  def new_type
    @groups = TpoGroup.all
  end

  def new_type_create
    if params[:group_id].present? && params[:type_name].present?
      type = TpoType.find_by(name: params[:type_name], tpo_group_id: params[:group_id])
      if !type.present?
        type = TpoType.create(name: params[:type_name], tpo_group_id: params[:group_id])
      end
      redirect_to new_tpo_listen_path(type_id: type.id)
    else
      redirect_to new_type_tpo_listens_path, notice: "套数、题目不能为空！"
    end
  end

  def new
    @type = TpoType.find params[:type_id]
  end

  def create
    count = TpoQuestion.where(tpo_type_id: params[:type_id]).count
    question = TpoQuestion.new
    question.content = params[:content]
    question.tpo_type_id = params[:type_id]
    question.sequence_number = count + 1
    if question.save
      if params[:resolution].present?
        TpoResolution.create(content: params[:resolution],tpo_question_id: question.id,user_id: 1)
      end
      if params[:sample].present?
        TpoSample.create(content: params[:sample],tpo_question_id: question.id,user_id: 1,standpoint: 1)
      end

      if question.tpo_type.name == 'Integrated'
        b = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.assessmentItem 'xmlns'=>"http://www.imsglobal.org/xsd/imsqti_v2p1", 'xmlns:xsi'=>"http://www.w3.org/2001/XMLSchema-instance",
          'xsi:schemaLocation'=>"http://www.imsglobal.org/xsd/imsqti_v2p1  http://www.imsglobal.org/xsd/qti/qtiv2p1/imsqti_v2p1.xsd", 'identifier'=>"extendedText1",
          'title'=>"Writing a Postcard", 'adaptive'=>"false", 'timeDependent'=>"false" do
            xml.responseDeclaration 'identifier'=>"RESPONSE", 'cardinality'=>"single", 'baseType'=>"string"
            xml.outcomeDeclaration 'identifier'=>"SCORE", 'cardinality'=>"single", 'baseType'=>"float"

            xml.itemBody do
              xml.p "#{params[:contents_articles]}"
              xml.p "#{params[:listening_script]}"
              xml.audio do
                xml.source 'src'=>"#{params[:url]}", 'type'=>"audio/mpeg"
              end
              xml.extendedTextInteraction 'responseIdentifier'=>"RESPONSE", 'expectedLength'=>"200" do
                xml.prompt "#{params[:listening_script]}"
              end
            end
          end
        end
        xml_file = File.new("#{Rails.root}/public/system/xml/writing/#{question.id}.xml", 'wb') #{ |f| f.write(b.to_xml) }
        xml_file.puts b.to_xml #写入数据
        xml_file.close #关闭文件流
      end
    end
    redirect_to writ_index_tpo_questions_path
  end

  def destroy
    tpo = TpoQuestion.find params[:id]
    if tpo.tpo_type.name == "Integrated"
      tpo.destroy
      system("rm public/system/xml/syntax/#{params[:id]}.xml")
    else
      tpo.destroy
    end
    redirect_to writ_index_tpo_questions_path
  end
end
