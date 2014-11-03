class AddAnalysisToJinghuaQuestions < ActiveRecord::Migration
  def change
    add_column :jinghua_questions, :analysis, :string
  end
end
