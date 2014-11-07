# encoding: utf-8
class JijingGroup < ActiveRecord::Base
  has_many :jijing_tasks
  has_many :jijing_works
end
