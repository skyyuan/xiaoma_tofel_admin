# encoding: utf-8
class TpoSpokensController < ApplicationController
  def index
    type_id = TpoType.where(name: ["Task1","Task2","Task3","Task4","Task5","Task6"]).map &:id
    @questions = TpoQuestion.where(tpo_type_id: type_id).order("created_at desc").page(params[:page])
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
      redirect_to new_tpo_spoken_path(type_id: type.id)
    else
      redirect_to new_type_tpo_spokens_path, notice: "套数、题目不能为空！"
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
    question.analysis = params[:analysis]
    if question.save
      if params[:resolution].present?
        TpoResolution.create(content: params[:resolution],tpo_question_id: question.id,user_id: 1)
      end
      if params[:sample].present?
        TpoSample.create(content: params[:sample],tpo_question_id: question.id,user_id: 1)
      end

      if question.tpo_type.name == 'Task3' || question.tpo_type.name == 'Task4' || question.tpo_type.name == 'Task5' || question.tpo_type.name == 'Task6'
        b = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.assessmentItem 'xmlns'=>"http://www.imsglobal.org/xsd/imsqti_v2p1", 'xmlns:xsi'=>"http://www.w3.org/2001/XMLSchema-instance",
          'xsi:schemaLocation'=>"http://www.imsglobal.org/xsd/imsqti_v2p1  http://www.imsglobal.org/xsd/qti/qtiv2p1/imsqti_v2p1.xsd", 'identifier'=>"extendedText1",
          'title'=>"Writing a Postcard", 'adaptive'=>"false", 'timeDependent'=>"false" do
            xml.responseDeclaration 'identifier'=>"RESPONSE", 'cardinality'=>"single", 'baseType'=>"string"
            xml.outcomeDeclaration 'identifier'=>"SCORE", 'cardinality'=>"single", 'baseType'=>"float"

            xml.itemBody do
              if params[:contents_articles].present?
                xml.p "#{params[:contents_articles]}"
              end
              if params[:listening_script].present?
                xml.p "#{params[:listening_script]}"
              end
              xml.audio do
                xml.source 'src'=>"#{params[:url]}", 'type'=>"audio/mpeg"
              end
              xml.extendedTextInteraction 'responseIdentifier'=>"RESPONSE", 'expectedLength'=>"200" do
                xml.prompt "#{params[:title]}"
              end
            end
          end
        end
        xml_file = File.new("#{Rails.root}/public/system/xml/speaking/#{question.id}.xml", 'wb') #{ |f| f.write(b.to_xml) }
        xml_file.puts b.to_xml #写入数据
        xml_file.close #关闭文件流
      end
    end
    redirect_to tpo_spokens_path
  end

  def destroy
    tpo = TpoQuestion.find params[:id]
    number = tpo.sequence_number
    type_id = tpo.tpo_type_id
    system("rm public/system/xml/speaking/#{params[:id]}.xml") if tpo.tpo_type.name == 'Task3' || tpo.tpo_type.name == 'Task4' || tpo.tpo_type.name == 'Task5' || tpo.tpo_type.name == 'Task6'
    if tpo.destroy
      questions = TpoQuestion.where("sequence_number > ? and tpo_type_id = ?", number, type_id)
      questions.each do |quesion|
        quesion.sequence_number = quesion.sequence_number.to_i - 1
        quesion.save
      end
    end
    redirect_to tpo_spokens_path
  end
end
