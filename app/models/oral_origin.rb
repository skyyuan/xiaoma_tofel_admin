# encoding: utf-8

class OralOrigin < ActiveRecord::Base

  attr_accessible :name

  has_many :oral_groups

  def self.name_for_selection
    OralOrigin.where(true).map {|oral_origin| [oral_origin.name.split('tpo')[1], oral_origin.id]}
  end
end
