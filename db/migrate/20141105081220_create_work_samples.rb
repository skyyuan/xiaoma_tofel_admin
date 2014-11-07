class CreateWorkSamples < ActiveRecord::Migration
  def change
    create_table :work_samples do |t|
      t.string :standpoint
      t.text :content
      t.references :jijing_work, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
