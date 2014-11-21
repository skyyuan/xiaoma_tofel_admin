# encoding: utf-8

class OralQuestion < ActiveRecord::Base
  attr_accessible :sequence_number, :data_url, :original_text, :oral_group_id

  belongs_to :oral_group
end
