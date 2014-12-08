# encoding: utf-8

class DictationGroup < ActiveRecord::Base

  attr_accessible :name

  validates :name, uniqueness: true

  has_many :dictation_questions, dependent: :destroy

  def self.short_name_for_selection
    DictationGroup.order('CONVERT(name,SIGNED)').map {|dictation_group| [dictation_group.name, dictation_group.id]}
  end

  def self.name_for_selection
    DictationGroup.order('CONVERT(name,SIGNED)').map {|dictation_group| ["unit#{dictation_group.name}", dictation_group.id]}
  end
end
