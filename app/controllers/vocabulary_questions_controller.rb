# encoding: utf-8
# -*- encoding: utf-8 -*-
require 'nokogiri'
require 'spreadsheet'
class VocabularyQuestionsController < ApplicationController

  def index
    @vocabularies = VocabularyQuestion.order("id desc").page(params[:page]).per(15)
  end

  def index_upload

  end

  def upload_vocabulary
    if params[:upload].present?
      file = params[:upload]
      file_name = file.original_filename.split(".")
      if file_name.last == 'xls'
        File.open("#{Rails.root}/public/system/xls/#{file.original_filename}", "wb+") do |f|
          f.write(file.read)
        end
        Spreadsheet.client_encoding ="UTF-8"
        book = Spreadsheet.open "#{Rails.root}/public/system/xls/#{file.original_filename}"
        sheet1 = book.worksheet 0
        sheet1.each do |row|
          next if row[0] == 'TPO编号' || row[1].blank?
          rand_num = rand(1..4)
          b = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
            xml.assessmentItem 'xmlns'=>"http://www.imsglobal.org/xsd/imsqti_v2p1", 'xmlns:xsi'=>"http://www.w3.org/2001/XMLSchema-instance",
            'xsi:schemaLocation'=>"http://www.imsglobal.org/xsd/imsqti_v2p1  http://www.imsglobal.org/xsd/qti/qtiv2p1/imsqti_v2p1.xsd", 'identifier'=>"choice",
            'title'=>"Unattended Luggage", 'adaptive'=>"false", 'timeDependent'=>"false" do
              xml.responseDeclaration 'identifier'=>"RESPONSE", 'cardinality'=>"single", 'baseType'=>"identifier" do
                xml.correctResponse do
                  if rand_num == 1
                    xml.value "A"
                  end
                  if rand_num == 2
                    xml.value "B"
                  end
                  if rand_num == 3
                    xml.value "C"
                  end
                  if rand_num == 4
                    xml.value "D"
                  end
                end
              end
              xml.itemBody do
                xml.explanation "#{row[4]}#{row[3]}"
                xml.symbols "#{row[5]}"
                xml.audio do
                  xml.url "#{row[6]}"
                end
                xml.choiceInteraction 'responseIdentifier'=>"RESPONSE", 'shuffle'=>"false", 'maxChoices'=>"1" do
                  xml.prompt "#{row[2]}"
                  ['A','B','C','D'].each_with_index do |i,index|
                    if (index+1) == rand_num
                      xml.simpleChoice "#{row[3]}", 'identifier'=>"#{i}"
                    else
                      count = rand(sheet1.count)
                      if count == 0
                        count = count + 1
                      end
                      xml.simpleChoice "#{sheet1.row(count)[3]}", 'identifier'=>"#{i}"
                    end
                  end
                end
              end
              xml.responseProcessing 'template'=>"http://www.imsglobal.org/question/qti_v2p1/rptemplates/match_correct"
            end
          end
          if File.exist?("#{Rails.root}/public/system/xml/word/#{row[2]}.xml") == true
            system("rm public/system/xml/word/#{row[2]}.xml")
          end
          xml_file = File.new("#{Rails.root}/public/system/xml/word/#{row[2]}.xml", 'wb') #{ |f| f.write(b.to_xml) }
          xml_file.puts b.to_xml #写入数据
          xml_file.close #关闭文件流
          @voc = VocabularyQuestion.find_by_word(row[2])
          if @voc.present?
            @voc.destroy
          end
          group = VocabularyGroup.find_by_sequence_number(row[1])
          count = VocabularyQuestion.where(vocabulary_group_id: group.id).count
          vocabulary = VocabularyQuestion.new
          vocabulary.sequence_number = count + 1
          vocabulary.content = b.to_xml
          vocabulary.vocabulary_group_id = group.id
          vocabulary.word = row[2]
          vocabulary.save
        end
        system("rm public/system/xls/#{file.original_filename}")
        redirect_to vocabulary_questions_path and return
      else
        redirect_to index_upload_vocabulary_questions_path, notice: "请上传XLS格式文件!" and return
      end
    else
      redirect_to index_upload_vocabulary_questions_path, notice: "请上传XLS格式文件!" and return
    end
  end
end
