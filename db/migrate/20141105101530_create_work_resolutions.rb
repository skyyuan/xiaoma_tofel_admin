class CreateWorkResolutions < ActiveRecord::Migration
  def change
    create_table :work_resolutions do |t|
      t.text :content
      t.references :jijing_work, index: true

      t.timestamps
    end
  end
end
