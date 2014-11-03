class RenameTypeToJinghuaQuestions < ActiveRecord::Migration
  change_table :jinghua_questions do |t|
  	t.rename :type, :content_type
  end
end
