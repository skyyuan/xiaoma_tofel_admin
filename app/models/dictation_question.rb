# encoding: utf-8
class DictationQuestion < ActiveRecord::Base

  attr_accessible :audio_url, :sample, :dictation_group_id, :sequence_number

  belongs_to :dictation_group
end
