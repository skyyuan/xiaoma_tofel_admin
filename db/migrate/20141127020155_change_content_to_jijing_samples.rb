class ChangeContentToJijingSamples < ActiveRecord::Migration
  def change
    change_column :jijing_samples, :content, :text
  end
end
