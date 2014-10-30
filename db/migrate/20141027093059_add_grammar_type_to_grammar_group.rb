class AddGrammarTypeToGrammarGroup < ActiveRecord::Migration
  def change
    add_reference :grammar_groups, :grammar_type, index: true
  end
end
