class TpoGroup < ActiveRecord::Base

  attr_accessible :name

  has_many :tpo_types, dependent: :destroy

  def self.name_for_selection
    TpoGroup.all.map {|tpo_group| [tpo_group.name, tpo_group.id]}
  end
end
