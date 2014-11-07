class CreateJinghuaSamples < ActiveRecord::Migration
  def change
    create_table :jinghua_samples do |t|
      t.string :content
      t.references :user, index: true

      t.timestamps
    end
  end
end
