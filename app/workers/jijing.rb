# encoding: utf-8
require 'spreadsheet'
class Jijing
  include Sidekiq::Worker
  sidekiq_options :queue => :jijing_xls
  def perform(name)
    Spreadsheet.client_encoding ="UTF-8"
    book = Spreadsheet.open "#{Rails.root}/public/system/xls/#{name}"
    sheet1 = book.worksheet 0
    sheet1.each do |row|
      next if row[1] == '题号' || row[0].blank? || row[1].blank? || row[2].blank?
      jijing_group = JijingGroup.find_by_name row[0]
      if !jijing_group.present?
        jijing_group = JijingGroup.new
      end
      jijing_group.name = row[0]
      jijing_group.group_type = 2
      if jijing_group.save
        question = JijingQuestion.new
        question.sequence_number = row[1].to_i
        question.jijing_group_id = jijing_group.id
        question.content = row[2]
        question.analysis = row[3]
        question.question_type = row[5] == '口语' ? 1 : 2
        if question.save
          if row[4].present?
            samp = JijingSample.new
            samp.content = row[4]
            samp.user_id = 1
            samp.jijing_question_id = question.id
            samp.save
          end
        end
      end
    end
    system("rm public/system/xls/#{name}")
    # sleep(60)
  end
end