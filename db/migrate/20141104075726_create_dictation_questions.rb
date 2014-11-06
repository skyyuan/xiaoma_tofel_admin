class CreateDictationQuestions < ActiveRecord::Migration
  def change
    create_table :dictation_questions do |t|
      t.string :audio_url
      t.text :sample
      t.references :dictation_group, index: true

      t.timestamps
    end
  end
end
