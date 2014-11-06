class AddJijingQuestionToJijingSample < ActiveRecord::Migration
  def change
    add_reference :jijing_samples, :jijing_question, index: true
  end
end
