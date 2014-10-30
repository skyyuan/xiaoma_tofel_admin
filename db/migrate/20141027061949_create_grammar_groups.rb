class CreateGrammarGroups < ActiveRecord::Migration
  def change
    create_table :grammar_groups do |t|
      t.string :sequence_number
      t.string :group_type

      t.timestamps
    end
  end
end
