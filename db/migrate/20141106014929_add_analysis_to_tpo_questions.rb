class AddAnalysisToTpoQuestions < ActiveRecord::Migration
  def change
    add_column :tpo_questions, :analysis, :string
  end
end
