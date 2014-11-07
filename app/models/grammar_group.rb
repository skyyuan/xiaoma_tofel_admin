# -*- encoding : utf-8 -*-
class GrammarGroup < ActiveRecord::Base
  validates_uniqueness_of :sequence_number, message: "单元已存在！"
  has_many :grammar_questions
end
