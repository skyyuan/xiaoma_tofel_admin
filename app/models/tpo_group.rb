class TpoGroup < ActiveRecord::Base
  has_many :tpo_types

  def self.name_for_selection
    TpoGroup.all.map {|tpo_group| [tpo_group.name, tpo_group.id]}
  end
end
