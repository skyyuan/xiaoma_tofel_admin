# encoding: utf-8

module TpoListenQuestion
  extend ActiveSupport::Concern

  module ClassMethods
    def listen_content_fromat_xml(options, tpo_type_name)
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
            xml.responseDeclaration 'identifier' => "RESPONSE#{num}", 'cardinality' => 'single', 'baseType' => 'identifier' do
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
                end
              end
            end
          end

          xml.outcomeDeclaration 'identifier' => "SCORE", 'cardinality' => "single", 'baseType' => "integer"

          xml.itemBody do
            # 文章
            xml.blockquote do
              xml.audio do
                xml.source 'src' => options[:audio]
              end
              material = options[:material]
              roles = ('a'..'e').to_a
              material_roles = []
              case tpo_type_name
              when 'Lecture'
                xml.p material
              when 'Conversion'
                materials = material.split(TpoQuestion::LISTEN_QUESTION_MATERIAL_MARKER)
                materials.each do |section|
                  role, content = section.split('=').map{|role_content| role_content.strip }
                  next if role.blank?
                  material_roles.push(role) unless material_roles.include?(role)
                  role_idx = material_roles.index(role)
                  xml.send("p_#{roles[role_idx]}", "#{role}:#{content}")
                end
              end
            end

            question_count.times do |idx|
              num = (idx + 1).to_s
              tpo_question_options = tpo_questions[num]
              question_type = tpo_question_options[:question_type]
              # 名师讲解-视频地址
              xml.audio do
                xml.source 'src' => tpo_question_options[:audio]
              end
              # 解析
              xml.p tpo_question_options[:analysis]

              #问题及选项
              xml.choiceInteraction 'responseIdentifier' => "RESPONSE#{num}", 'shuffle' => "false", 'maxChoices' => "#{question_type}" do
                xml.prompt tpo_question_options[:prompt]
                tpo_question_options[:option].each do |option, content|
                  xml.simpleChoice content, 'identifier' => option
                end
              end
            end
          end
          xml.responseProcessing 'template'=>"http://www.imsglobal.org/question/qti_v2p1/rptemplates/match_correct"
        end
      end

      content_builder.to_xml
    end

    def listen_batch_import(read_file)
      Spreadsheet.client_encoding ="UTF-8"
      read_sheet = Spreadsheet.open read_file.path
      # section_sheet = read_sheet.worksheet 0
      question_sheet = read_sheet.worksheet 0
      alps = ('A'..'F').to_a
      tpos = []
      question_content_rows = {}
      question_sheet.each_with_index do |question_row, question_idx|
        next if question_idx.zero?
        tpo_group_name = question_row[0].to_i
        tpo_type_name = question_row[1].to_i # 1 => conversation, 2 => lecture
        sequence_number = question_row[3]
        next if tpo_group_name.blank? || tpo_type_name.blank? || sequence_number.blank?
        if question_content_row.keys.include?(tpo_group_name)
      end


      # question_sheet.each_with_index do |section_row, section_idx|
      question_sheet.each_with_index do |question_row, question_idx|
        next if question_idx.zero?
        tpo_group_name = question_row[0].to_i
        tpo_type_name = question_row[1].to_i # 1 => conversation, 2 => lecture
        sequence_number = question_row[3]
        next if tpo_group_name.blank? || tpo_type_name.blank? || sequence_number.blank?

        question_content_rows = [] # 所属文章的小题row number
        questioin_sheet.each_with_index do |content_row, content_idx|
          next if content_idx.zero?
          content_tpo_group_name = question_row[0].to_i
          content_tpo_group_name = question_row[0].to_i
          content_tpo_type_name = question_row[1].to_i
          content_sequence_number = question_row[3]
          next if content_tpo_group_name.blank? || content_tpo_type_name.blank? || content_sequence_number.blank?

          if tpo_group_name == content_tpo_group_name
            question_content_rows.push(content_idx)
          end
        end

        content_builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.assessmentItem 'xmlns'=>"http://www.imsglobal.org/xsd/imsqti_v2p1", 'xmlns:xsi'=>"http://www.w3.org/2001/XMLSchema-instance",
          'xsi:schemaLocation'=>"http://www.imsglobal.org/xsd/imsqti_v2p1  http://www.imsglobal.org/xsd/qti/qtiv2p1/imsqti_v2p1.xsd", 'identifier'=>"choice",
          'title'=>"", 'adaptive'=>"false", 'timeDependent'=>"false" do
            # 遍历每一道题
            question_content_rows.each_with_index do |question_content_row, idx|
              num = (idx + 1).to_s
              # tpo_question_options = tpo_questions[num]
              question_content = questioin_sheet.row(question_content_row)
              question_type = tpo_question_options[:question_type]
              xml.responseDeclaration 'identifier' => "RESPONSE#{num}", 'cardinality' => 'single', 'baseType' => 'identifier' do
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
                  end
                end
              end
            end

            xml.outcomeDeclaration 'identifier' => "SCORE", 'cardinality' => "single", 'baseType' => "integer"

            xml.itemBody do
              # 文章
              xml.blockquote do
                xml.audio do
                  xml.source 'src' => options[:audio]
                end
                material = options[:material]
                roles = ('a'..'e').to_a
                material_roles = []
                case tpo_type_name
                when 'Lecture'
                  xml.p material
                when 'Conversion'
                  materials = material.split(TpoQuestion::LISTEN_QUESTION_MATERIAL_MARKER)
                  materials.each do |section|
                    role, content = section.split('=').map{|role_content| role_content.strip }
                    next if role.blank?
                    material_roles.push(role) unless material_roles.include?(role)
                    role_idx = material_roles.index(role)
                    xml.send("p_#{roles[role_idx]}", "#{role}:#{content}")
                  end
                end
              end

              question_count.times do |idx|
                num = (idx + 1).to_s
                tpo_question_options = tpo_questions[num]
                question_type = tpo_question_options[:question_type]
                # 名师讲解-视频地址
                xml.audio do
                  xml.source 'src' => tpo_question_options[:audio]
                end
                # 解析
                xml.p tpo_question_options[:analysis]

                #问题及选项
                xml.choiceInteraction 'responseIdentifier' => "RESPONSE#{num}", 'shuffle' => "false", 'maxChoices' => "#{question_type}" do
                  xml.prompt tpo_question_options[:prompt]
                  tpo_question_options[:option].each do |option, content|
                    xml.simpleChoice content, 'identifier' => option
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
          tpo_type = TpoType.where(tpo_group_id: tpo_group.id, name: 'Passage').first
          unless tpo_type
            tpo_type = TpoType.new
            tpo_type.name = 'Passage'
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
      # puts "~~~~~~~~~~~~~#{question_sheet.columns[0].count}"
    end

  end #ClassMethods

  def parse_listen_xml_to_object
    content_xml = Nokogiri::XML(content)
    tpo_questions = {}
    blockquote_tag = content_xml.css('assessmentItem itemBody blockquote')
    tpo_questions[:audio] = blockquote_tag.search('audio source')[0].attribute('src').content
    tpo_questions[:title] = content_xml.css('assessmentItem').attribute('title').content
    tpo_type_name = tpo_type.name
    tpo_questions[:material] = if tpo_type_name == 'Lecture'
      blockquote_tag.search('p')[0].content
    elsif tpo_type_name == 'Conversion'
      section_tags = []
      materials = ''
      blockquote_tag.search('audio ~ *').each do |section|
        section_content = section.content.split(':')
        role = section_content.shift
        materials = materials + "#{role}=#{section_content.join(':')}{ITEM}\r\n"
      end
      puts "~~~~~materials~~~~#{materials.inspect}~~~"
      materials
    end

    response_declarations = content_xml.css('responseDeclaration')
    question_nums = response_declarations.count # 总题数
    choice_interactions = content_xml.css('choiceInteraction') # 单/多选题
    choice_interaction_nums = choice_interactions.count
    analysis = content_xml.css('assessmentItem itemBody > p')
    audios = content_xml.css('assessmentItem itemBody > audio')
    tpo_questions[:tpo_question] = {}
    question_nums.times do |idx|
      num = (idx + 1).to_s
      tpo_questions[:tpo_question][num] = {}
      question_options = tpo_questions[:tpo_question][num]
      question_options[:option] = {}
      tpo_questions[:tpo_question][num][:answer] = []
      choice_interaction = choice_interactions[idx]
      question_options[:question_type] = choice_interaction.attribute('maxChoices').content
      question_options[:prompt] = choice_interaction.search('prompt')[0].content
      options = choice_interaction.search('simpleChoice')
      response_declarations[idx].search('correctResponse value').each do |answer|
        question_options[:answer].push(answer.content)
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
