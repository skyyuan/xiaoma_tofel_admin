class AddJinghuaQuestionToJinghuaSample < ActiveRecord::Migration
  def change
    add_reference :jinghua_samples, :jinghua_question, index: true
  end
end
