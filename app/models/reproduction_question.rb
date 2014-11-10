# encoding: utf-8

class ReproductionQuestion < ActiveRecord::Base
  has_many :reproduction_samples, dependent: :destroy
end
