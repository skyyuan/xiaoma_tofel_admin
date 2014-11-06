class CreateTpoResolutions < ActiveRecord::Migration
  def change
    create_table :tpo_resolutions do |t|
      t.text :content
      t.references :tpo_question, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
