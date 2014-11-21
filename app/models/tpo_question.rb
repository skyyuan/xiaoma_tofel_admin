# encoding: utf-8

class TpoQuestion < ActiveRecord::Base
  include TpoReadQuestion
  include TpoListenQuestion

  attr_accessible :content, :sequence_number, :tpo_type_id

  READ_QUESTION_TYPE = {1 => '单选', 2 => '多选', 3 => '拖拽'}
  READ_QUESTION_SIMPLE_CHOICE = {A: 'choiceA', B: 'choiceB', C: 'choiceC', D: 'choiceD'}
  READ_QUESTION_MULTIPLE_CHOICE = {A: 'choiceA', B: 'choiceB', C: 'choiceC', D: 'choiceD', E: 'choiceE'}
  LISTEN_QUESTION_TYPE = {1 => '单选', 2 => '多选'}
  LISTEN_QUESTION_MATERIAL_MARKER = '{ITEM}'

  belongs_to :tpo_type
  has_many :tpo_resolutions
  has_many :tpo_samples

  def self.parse_audio(audio)
    audios = audio.split('vid=')
    audios = audios[1].split('&') if audios.count > 1
    audios[0]
  end
end
