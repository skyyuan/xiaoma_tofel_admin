class RemoveJijingGroupToJijingQuestions < ActiveRecord::Migration
  change_table :jijing_questions do |t|
    t.remove :jijing_group_id_id
    t.references :jijing_group
  end
end
