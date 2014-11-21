# encoding: utf-8

class ReproductionQuestion < ActiveRecord::Base
  has_many :reproduction_samples, dependent: :destroy

  attr_accessible :content, :content_ch, :sequence_number
end
