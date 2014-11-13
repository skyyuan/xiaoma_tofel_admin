# encoding: utf-8

class TpoQuestion < ActiveRecord::Base
  READ_QUESTION_TYPE = {1 => '单选', 2 => '多选', 3 => '拖拽'}
  READ_QUESTION_SIMPLE_CHOICE = {A: 'choiceA', B: 'choiceB', C: 'choiceC', D: 'choiceD'}
  READ_QUESTION_MULTIPLE_CHOICE = {A: 'choiceA', B: 'choiceB', C: 'choiceC', D: 'choiceD', E: 'choiceE'}

  belongs_to :tpo_type
  has_many :tpo_resolutions
  has_many :tpo_samples

  def self.read_content_fromat_xml(options)
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
            cardinality = 'multiple'
            baseType = 'directedPair'
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
                tpo_question_options[:answer].each do |answer|
                  xml.value answer
                end
              when '3'
                # 托拽
                # <value>F G1</value>
                # <value>C G2</value>
                tpo_question_options[:answer1].each do |answer|
                  xml.value "#{answer} G1"
                end

                tpo_question_options[:answer2].each do |answer|
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

  def parse_xml_to_object
    content_xml = Nokogiri::XML(content)
    tpo_questions = Hash.new([])
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
      tpo_questions[:tpo_question][num] = Hash.new([])
      question_options = tpo_questions[:tpo_question][num]
      question_options[:option] = {}
      # 托拽题
      if question_nums > choice_interaction_nums && question_nums == num.to_i
        question_options[:question_type] = '3'
        question_options[:options]
        options = gap_match_interaction.search('gapText')
        gaps = gap_match_interaction.search('blockquote p gap')
        question_options[:G1] = gaps[0].previous.try(:content)
        question_options[:G2] = gaps[1].previous.try(:content)
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
        choice_interaction = choice_interactions[idx]
        question_options[:question_type] = choice_interaction.attribute('maxChoices')
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
        question_options[:option][options[choice_idx].attribute('identifier')] = options[choice_idx].content
      end
      question_options[:analysis] = analysis[idx].content
      question_options[:audio] = audios[idx].search('source')[0].attribute('src')
    end
    puts "~~~~~~~~~~~~~~~~~~tpo_questions~~~~~#{tpo_questions}"
    tpo_questions
  end
end
