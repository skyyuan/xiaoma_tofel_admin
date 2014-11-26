# encoding: utf-8
class JinghuaQuestion < ActiveRecord::Base
  attr_accessible :content, :content_type, :analysis
  TYPE_NAME = [["人物类","1"],["事件类","2"],["地点类","3"],["物品类","4"],["其他类","5"]]

  def type_name
    if self.content_type.to_i == 1
      "人物类"
    elsif self.content_type.to_i == 2
      "事件类"
    elsif self.content_type.to_i == 3
      "地点类"
    elsif self.content_type.to_i == 4
      "物品类"
    elsif self.content_type.to_i == 5
      "其他类"
    end
  end
end
