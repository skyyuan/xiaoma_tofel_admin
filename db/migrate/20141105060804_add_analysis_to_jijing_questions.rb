class AddAnalysisToJijingQuestions < ActiveRecord::Migration
  def change
    add_column :jijing_questions, :analysis, :string
  end
end
