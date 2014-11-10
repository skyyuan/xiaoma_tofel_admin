# encoding: utf-8
class TpoQuestionsController < ApplicationController
  def index
  end

  def writ_index
    @questions = TpoQuestion.order("created_at desc").page(params[:page])
  end

  def writ_new_type
    @groups = TpoGroup.all
  end

  def writ_new_type_create
    if params[:group_id].present? && params[:type_name].present?
      type = TpoType.find_by(name: params[:type_name], tpo_group_id: params[:group_id])
      if !type.present?
        type = TpoType.create(name: params[:type_name], tpo_group_id: params[:group_id])
      end
      redirect_to writ_new_tpo_questions_path(type_id: type.id)
    else
      redirect_to writ_new_type_tpo_questions_path, notice: "套数、题目不能为空！"
    end
  end

  def writ_new
    @type = TpoType.find params[:type_id]
  end

  def create

    @type = TpoType.find params[:type_id]
    if @type.name == 'Integrated'
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
          TpoSample.create(content: params[:sample],tpo_question_id: question.id,user_id: 1)
        end
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
                xml.prompt "#{params[:title] if params[:title].present? }"
              end
            end
          end
        end
        xml_file = File.new("#{Rails.root}/public/system/xml/writing/#{question.id}.xml", 'wb') #{ |f| f.write(b.to_xml) }
        xml_file.puts b.to_xml #写入数据
        xml_file.close #关闭文件流
      end
    else
      count = TpoQuestion.where(tpo_type_id: params[:type_id]).count
      question = TpoQuestion.new
      question.content = params[:content]
      question.tpo_type_id = params[:type_id]
      question.sequence_number = count + 1
      if question.save
        if params[:resolution].present?
          TpoResolution.create(content: params[:resolution],tpo_question_id: question.id,user_id: 1)
        end
        params[:standpoint].each_with_index do |standpoint,i|
          TpoSample.create(content: params[:sample][i],standpoint: standpoint,tpo_question_id: question.id,user_id: 1)
        end
      end
    end
    redirect_to writ_index_tpo_questions_path
  end

  def destroy
    tpo = TpoQuestion.find params[:id]
    if tpo.tpo_type.name == "Integrated"
      tpo.destroy
      system("rm public/system/xml/writing/#{params[:id]}.xml")
    else
      tpo.destroy
    end
    redirect_to writ_index_tpo_questions_path
  end
end