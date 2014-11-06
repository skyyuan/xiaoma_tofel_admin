class AddSequenceNumberToDictationQuestions < ActiveRecord::Migration
  def change
    add_column :dictation_questions, :sequence_number, :integer
  end
end
