class AddRemarkToJinghuaAnswers < ActiveRecord::Migration
  def change
    add_column :jinghua_answers, :remark, :string
  end
end
