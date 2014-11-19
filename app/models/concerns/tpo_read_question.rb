# encoding: utf-8

module TpoReadQuestion
  extend ActiveSupport::Concern

  module ClassMethods
    def read_content_fromat_xml(options)
      content_builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.assessmentItem 'xmlns'=>"http://www.imsglobal.org/xsd/imsqti_v2p1", 'xmlns:xsi'=>"http://www.w3.org/2001/XMLSchema-instance",
        'xsi:schemaLocation'=>"http://www.imsglobal.org/xsd/imsqti_v2p1  http://www.imsglobal.org/xsd/qti/qtiv2p1/imsqti_v2p1.xsd", 'identifier'=>"choice",
        'title'=>"#{options[:title]}", 'adaptive'=>"false", 'timeDependent'=>"false" do
          tpo_questions = options[:tpo_question]
          question_count = tpo_questions.size
          # 遍历每一道题
          question_count.times do |idx|
            num = (idx + 1).to_s
            tpo_question_options = tpo_questions[num]
            question_type = tpo_question_options[:question_type]
            if question_type == '3'
              cardinality = 'complex'
              baseType = 'directedPair'
            elsif question_type == '2'
              cardinality = 'multiple'
              baseType = 'identifier'
            else
              cardinality = 'single'
              baseType = 'identifier'
            end
            xml.responseDeclaration 'identifier' => "RESPONSE#{num}", 'cardinality' => "#{cardinality}", 'baseType' => "#{baseType}" do
              xml.correctResponse do
                case question_type
                when '1'
                  # 单选
                  # <value>ChoiceA</value>
                  xml.value tpo_question_options[:answer]
                when '2'
                  # 多选
                  # <value>ChoiceA</value>
                  # <value>ChoiceB</value>
                  (tpo_question_options[:answer] || []).each do |answer|
                    xml.value answer
                  end
                when '3'
                  # 托拽
                  # <value>F G1</value>
                  # <value>C G2</value>
                  (tpo_question_options[:answer1] || []).each do |answer|
                    xml.value "#{answer} G1"
                  end

                  (tpo_question_options[:answer2] || []).each do |answer|
                    xml.value "#{answer} G2"
                  end
                end
              end
            end
          end

          xml.outcomeDeclaration 'identifier' => "SCORE", 'cardinality' => "single", 'baseType' => "integer"

          xml.itemBody do
            # 文章
            xml.blockquote do
              options[:en].each_with_index do |en, idx|
                xml.p_en en
                xml.p_ch options[:ch][idx]
              end
            end

            question_count.times do |idx|
              num = (idx + 1).to_s
              tpo_question_options = tpo_questions[num]
              question_type = tpo_question_options[:question_type]
              # 解析
              xml.p tpo_question_options[:analysis]
              # 名师讲解-视频地址
              xml.audio do
                xml.source 'src' => tpo_question_options[:audio]
              end

              if question_type == '3'
                xml.gapMatchInteraction 'responseIdentifier' => "RESPONSE#{num}", 'shuffle' => "true" do
                  xml.prompt tpo_question_options[:prompt]
                  tpo_question_options[:option].each do |option, content|
                    xml.gapText content, 'identifier' => option, 'matchMax' => "1"
                  end
                  xml.blockquote do
                    xml.p do
                      xml.text tpo_question_options[:G1]
                      xml.gap 'identifier' => "G1"
                      xml.text tpo_question_options[:G2]
                      xml.gap 'identifier' => "G2"
                    end
                  end
                end
              else
                # # 解析
                # xml.p tpo_question_options[:analysis]
                # # 名师讲解-视频地址
                # xml.audio do
                #   xml.source 'src' => tpo_question_options[:audio]
                # end
                #问题及选项
                xml.choiceInteraction 'responseIdentifier' => "RESPONSE#{num}", 'shuffle' => "false", 'maxChoices' => "#{question_type}" do
                  xml.prompt tpo_question_options[:prompt]
                  tpo_question_options[:option].each do |option, content|
                    xml.simpleChoice content, 'identifier' => option
                  end
                end
              end
            end
          end
          xml.responseProcessing 'template'=>"http://www.imsglobal.org/question/qti_v2p1/rptemplates/match_correct"
        end
      end

      puts "~~~~~~~~~~~~~#{content_builder.to_xml}@@@@@@@@@@@@"
      content_builder.to_xml
    end

    def read_batch_import(read_file)
      Spreadsheet.client_encoding ="UTF-8"
      read_sheet = Spreadsheet.open read_file.path
      section_sheet = read_sheet.worksheet 0
      questioin_sheet = read_sheet.worksheet 1
      alps = ('A'..'G').to_a
      section_sheet.each_with_index do |section_row, section_idx|
        next if section_idx.zero?
        section_tpo_group_name = section_row[0].to_i
        section_tpo_type_name = section_row[1].to_i
        next if section_tpo_group_name.blank? || section_tpo_type_name.blank?

        question_content_rows = [] # 所属文章的小题row number
        questioin_sheet.each_with_index do |question_row, question_idx|
          next if question_idx.zero?
          question_tpo_group_name = question_row[0].to_i
          question_tpo_type_name = question_row[1].to_i
          next if question_tpo_group_name.blank? || question_tpo_type_name.blank?
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
                    answers1 = question_answer.split('/')[0]
                    answers2 = question_answer.split('/')[1]
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
                  xml.source 'src' => question_content[19]
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
                      xml.p do
                        xml.text question_content[6]
                        xml.gap 'identifier' => "G1"
                        xml.text question_content[7]
                        xml.gap 'identifier' => "G2"
                      end
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

        tpo_group = TpoGroup.where(name: ["tpo#{section_tpo_group_name}", "Tpo#{section_tpo_group_name}"]).first
        if tpo_group
          tpo_type = TpoType.where(tpo_group_id: tpo_group.id, name: 'passange').first
          unless tpo_type
            tpo_type = TpoType.new
            tpo_type.name = 'passange'
            tpo_type.tpo_group_id = tpo_group.id
            tpo_type.save
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
    end
  end # ClassMethods

  def parse_xml_to_object
    content_xml = Nokogiri::XML(content)
    tpo_questions = {en: [], ch: []}
    tpo_questions[:title] = content_xml.css('assessmentItem').attribute('title').content
    content_xml.css('itemBody p_en').each do |p_en|
      tpo_questions[:en].push(p_en.content)
    end

    content_xml.css('itemBody p_ch').each do |p_ch|
      tpo_questions[:ch].push(p_ch.content)
    end

    response_declarations = content_xml.css('responseDeclaration')
    question_nums = response_declarations.count # 总题数
    choice_interactions = content_xml.css('choiceInteraction') # 单/多选题
    choice_interaction_nums = choice_interactions.count
    gap_match_interaction = content_xml.css('gapMatchInteraction').first
    analysis = content_xml.css('assessmentItem p')
    audios = content_xml.css('assessmentItem audio')
    tpo_questions[:tpo_question] = {}
    question_nums.times do |idx|
      num = (idx + 1).to_s
      tpo_questions[:tpo_question][num] = {}
      question_options = tpo_questions[:tpo_question][num]
      question_options[:option] = {}
      # 托拽题
      if question_nums > choice_interaction_nums && question_nums == num.to_i
        question_options[:question_type] = '3'
        question_options[:options]
        options = gap_match_interaction.search('gapText')
        gaps = gap_match_interaction.search('blockquote p gap')
        question_options[:prompt] = gap_match_interaction.search('prompt')[0].content
        question_options[:G1] = gaps[0].previous.try(:content)
        question_options[:G2] = gaps[1].previous.try(:content)
        tpo_questions[:tpo_question][num][:answer1] = []
        tpo_questions[:tpo_question][num][:answer2] = []
        response_declarations[idx].search('correctResponse value').each do |answer|
          answer_content = answer.content
          if answer_content.include?('G1')
            question_options[:answer1].push(answer_content.split(' G1')[0])
          else
            question_options[:answer2].push(answer_content.split(' G2')[0])
          end
        end
        # question_options[:analysis] = gap_match_interaction.previous('p')[0].content
        # question_options[:audio] = gap_match_interaction.previous('audio')[0].search('source')[0].attribute('src')
      else # 单/多选题
        tpo_questions[:tpo_question][num][:answer] = []
        choice_interaction = choice_interactions[idx]
        question_options[:question_type] = choice_interaction.attribute('maxChoices').content
        question_options[:prompt] = choice_interaction.search('prompt')[0].content
        options = choice_interaction.search('simpleChoice')
        # options.count.times do |choice_idx|
        #   question_options[:option][options[choice_idx].attribute('identifier')] = options[choice_idx].content
        # end
        response_declarations[idx].search('correctResponse value').each do |answer|
          question_options[:answer].push(answer.content)
        end
        # question_options[:analysis] = choice_interaction.previous('p')[0].content
        # question_options[:audio] = choice_interaction.previous('audio')[0].search('source')[0].attribute('src')
      end
      options.count.times do |choice_idx|
        question_options[:option][options[choice_idx].attribute('identifier').content] = options[choice_idx].content
      end
      question_options[:analysis] = analysis[idx].content
      question_options[:audio] = audios[idx].search('source')[0].attribute('src').content
    end
    puts "~~~~~~~~~~~~~~~~~~tpo_questions~~~~~#{tpo_questions}"
    tpo_questions
  end
end
