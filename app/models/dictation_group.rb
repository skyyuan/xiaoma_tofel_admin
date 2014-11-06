# encoding: utf-8

class DictationGroup < ActiveRecord::Base
  validates :name, uniqueness: true

  has_many :dictation_questions

  def self.short_name_for_selection
    DictationGroup.all.map {|dictation_group| [dictation_group.name, dictation_group.id]}
  end

  def self.name_for_selection
    DictationGroup.all.map {|dictation_group| ["unit#{dictation_group.name}", dictation_group.id]}
  end

  def self.names
    DictationGroup.where(true).pluck(:name)
  end
end
