# encoding: utf-8
class DictationQuestion < ActiveRecord::Base
  belongs_to :dictation_group
end
