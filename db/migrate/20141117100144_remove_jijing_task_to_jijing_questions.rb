class RemoveJijingTaskToJijingQuestions < ActiveRecord::Migration
  change_table :jijing_questions do |t|
    t.remove :jijing_task_id
    t.references :jijing_group_id
  end
end
