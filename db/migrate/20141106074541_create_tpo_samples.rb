class CreateTpoSamples < ActiveRecord::Migration
  def change
    create_table :tpo_samples do |t|
      t.string :standpoint
      t.text :content
      t.references :tpo_question, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
