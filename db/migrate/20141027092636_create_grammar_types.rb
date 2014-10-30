class CreateGrammarTypes < ActiveRecord::Migration
  def change
    create_table :grammar_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
