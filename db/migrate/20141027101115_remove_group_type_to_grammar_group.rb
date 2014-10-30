class RemoveGroupTypeToGrammarGroup < ActiveRecord::Migration
  def change
  	remove_column :grammar_groups, :group_type, :string
  end
end
