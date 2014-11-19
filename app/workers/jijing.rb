# encoding: utf-8
require 'spreadsheet'
class Jijing
  include Sidekiq::Worker
  sidekiq_options :queue => :question_xls
  def perform(name)
    Spreadsheet.client_encoding ="UTF-8"
    book = Spreadsheet.open "#{Rails.root}/public/system/xls/#{name}"
    sheet1 = book.worksheet 0
    sheet1.each do |row|
      next if row[1] == '题号' || row[0].blank? || row[1].blank? || row[2].blank?
      question = JinghuaQuestion.new
      question.content = row[1]
      question.content_type = row[2].to_i
      question.analysis = row[4]
      question.save
    end
    system("rm public/system/xls/#{name}")
    sleep(60)
  end
end