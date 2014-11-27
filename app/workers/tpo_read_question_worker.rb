# encoding: utf-8

require 'nokogiri'
require 'spreadsheet'

class TpoReadQuestionWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :tpo_read_question_xls

  def perform(file_name)
    Spreadsheet.client_encoding ="UTF-8"
    file_path_name = "#{Rails.root}/public/system/xls/#{file_name}"
    read_sheet = Spreadsheet.open file_path_name
    section_sheet = read_sheet.worksheet 0
    questioin_sheet = read_sheet.worksheet 1
    alps = ('A'..'G').to_a
    section_sheet.each_with_index do |section_row, section_idx|
      next if section_idx.zero?
      section_tpo_group_name = section_row[0].to_i
      section_tpo_type_name = section_row[1].to_i
      next if section_tpo_group_name.zero? || section_tpo_type_name.zero?

      question_content_rows = [] # 所属文章的小题row number
      questioin_sheet.each_with_index do |question_row, question_idx|
        next if question_idx.zero?
        question_tpo_group_name = question_row[0].to_i
        question_tpo_type_name = question_row[1].to_i
        next if question_tpo_group_name.zero? || question_tpo_type_name.zero?
        if section_tpo_group_name == question_tpo_group_name && section_tpo_type_name == question_tpo_type_name
          question_content_rows.push(question_idx)
        end
      end

      content_builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.assessmentItem 'xmlns'=>"http://www.imsglobal.org/xsd/imsqti_v2p1", 'xmlns:xsi'=>"http://www.w3.org/2001/XMLSchema-instance",
        'xsi:schemaLocation'=>"http://www.imsglobal.org/xsd/imsqti_v2p1  http://www.imsglobal.org/xsd/qti/qtiv2p1/imsqti_v2p1.xsd", 'identifier'=>"choice",
        'title'=>"#{section_row[3]}", 'adaptive'=>"false", 'timeDependent'=>"false" do
          # 遍历每一道题
          question_content_rows.each_with_index do |question_content_row, idx|
            num = (idx + 1).to_s
            question_content = questioin_sheet.row(question_content_row)
            question_type = question_content[2].to_i
            if question_type == 3
              cardinality = 'complex'
              baseType = 'directedPair'
            elsif question_type == 2
              cardinality = 'multiple'
              baseType = 'identifier'
            else
              cardinality = 'single'
              baseType = 'identifier'
            end
            question_answer = question_content[15]
            xml.responseDeclaration 'identifier' => "RESPONSE#{num}", 'cardinality' => "#{cardinality}", 'baseType' => "#{baseType}" do
              xml.correctResponse do
                case question_type
                when 1
                  # 单选
                  # <value>ChoiceA</value>
                  xml.value "choice#{question_answer}"
                when 2
                  # 多选
                  # <value>ChoiceA</value>
                  # <value>ChoiceB</value>
                  (question_answer || '').each_char do |answer|
                    xml.value "choice#{answer}"
                  end
                when 3
                  # 托拽
                  # <value>F G1</value>
                  # <value>C G2</value>
                  answers1 = question_answer.split('/')[0].gsub(/\s/, '')
                  answers2 = question_answer.split('/')[1].gsub(/\s/, '')
                  (answers1 || '').each_char do |answer|
                    xml.value "choice#{answer} G1"
                  end

                  (answers2 || '').each_char do |answer|
                    xml.value "choice#{answer} G2"
                  end
                end
              end
            end
          end

          xml.outcomeDeclaration 'identifier' => "SCORE", 'cardinality' => "single", 'baseType' => "integer"

          xml.itemBody do
            # 文章
            en_distance = 3
            xml.blockquote do
              9.times do |idx|
                en_distance = en_distance + 1
                en_content = section_row[en_distance]
                break if en_content.blank?
                xml.p_en en_content
                en_distance = en_distance + 1
                xml.p_ch section_row[en_distance]
              end
            end

            question_content_rows.each_with_index do |question_content_row, idx|
              num = (idx + 1).to_s
              question_content = questioin_sheet.row(question_content_row)
              question_type = question_content[2].to_i
              # 解析
              xml.p question_content[16]
              # 名师讲解-视频地址
              xml.audio do
                xml.source 'src' => TpoQuestion.parse_audio(question_content[19])
              end

              if question_type == 3
                xml.gapMatchInteraction 'responseIdentifier' => "RESPONSE#{num}", 'shuffle' => "true" do
                  xml.prompt question_content[5]
                  option_distance =7
                  7.times do |option_idx|
                    option_distance += 1
                    option_content = question_content[option_distance]
                    break if option_content.blank?
                    xml.gapText option_content, 'identifier' => "choice#{alps[option_idx]}", 'matchMax' => "1"
                  end
                  xml.blockquote do
                    xml.G1 question_content[6]
                    xml.G2 question_content[7]
                    # xml.p do
                    #   xml.text question_content[6]
                    #   xml.gap 'identifier' => "G1"
                    #   xml.text question_content[7]
                    #   xml.gap 'identifier' => "G2"
                    # end
                  end
                end
              else
                #问题及选项
                xml.choiceInteraction 'responseIdentifier' => "RESPONSE#{num}", 'shuffle' => "false", 'maxChoices' => "#{question_type}" do
                  xml.prompt question_content[5]

                  option_distance =7
                  7.times do |option_idx|
                    option_distance += 1
                    option_content = question_content[option_distance]
                    break if option_content.blank?
                    xml.simpleChoice option_content, 'identifier' => "choice#{alps[option_idx]}"
                  end
                end
              end
            end
          end
          xml.responseProcessing 'template'=>"http://www.imsglobal.org/question/qti_v2p1/rptemplates/match_correct"
        end
      end

      #puts "~~~~~~~~~~~~~#{content_builder.to_xml}@@@@@@@@@@@@"

      tpo_group = TpoGroup.where(name: ["tpo#{section_tpo_group_name}", "Tpo#{section_tpo_group_name}", "TPO#{section_tpo_group_name}"]).first
      if tpo_group
        tpo_type = TpoType.where(tpo_group_id: tpo_group.id, name: 'passage').first
        unless tpo_type
          tpo_type = TpoType.new
          tpo_type.name = 'passage'
          tpo_type.tpo_group_id = tpo_group.id
          tpo_type.save
        end

        exist_tpo_question = TpoQuestion.where(tpo_type_id: tpo_type.id, sequence_number: section_tpo_type_name)
        if exist_tpo_question.exists?
          exist_tpo_question.delete_all
        end

        tpo_question = TpoQuestion.new
        tpo_question.tpo_type_id = tpo_type.id
        tpo_question.sequence_number = section_tpo_type_name
        content = content_builder.to_xml
        tpo_question.content = content
        if tpo_question.save
          File.open("#{Rails.root}/public/system/xml/tpo/reads/#{tpo_question.id}.xml", "wb") do |file|
            file.write content
          end
        end
      else
        logger.info "所属tpo不存在"
      end


    end
    # puts "~~~~~~~~~~~~~#{questioin_sheet.columns[0].count}"
    system("rm #{file_path_name}")
    sleep(60)
  end
end
