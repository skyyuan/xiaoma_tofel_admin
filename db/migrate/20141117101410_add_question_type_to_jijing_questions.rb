class AddQuestionTypeToJijingQuestions < ActiveRecord::Migration
  def change
    add_column :jijing_questions, :question_type, :string
  end
end
