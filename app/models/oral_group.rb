# encoding: utf-8

class OralGroup < ActiveRecord::Base
  ORAL_FROM = {'conversation1' => 'conversation1', 'conversation2' => 'conversation2', 'lecture1' => 'lecture1', 'lecture2' => 'lecture2',
    'lecture3' => 'lecture3', 'lecture4' => 'lecture4'}

  has_many :oral_questions
  belongs_to :oral_origin

  # def self.short_unit_for_selection
  #   OralGroup.order('sequence_number').map {|oral_group| [oral_group.sequence_number, oral_group.id]}
  # end

  def self.unit_for_selection
    OralGroup.order('CONVERT(sequence_number,SIGNED)').map {|oral_group| ["unit#{oral_group.sequence_number}", oral_group.id]}
  end
end
