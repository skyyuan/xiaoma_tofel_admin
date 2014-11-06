class CreateJijingSamples < ActiveRecord::Migration
  def change
    create_table :jijing_samples do |t|
      t.string :content
      t.references :user, index: true

      t.timestamps
    end
  end
end
