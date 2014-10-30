class CreateVocabularyGroups < ActiveRecord::Migration
  def change
    create_table :vocabulary_groups do |t|
      t.string :sequence_number

      t.timestamps
    end
  end
end
