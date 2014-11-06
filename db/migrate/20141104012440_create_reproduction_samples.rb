class CreateReproductionSamples < ActiveRecord::Migration
  def change
    create_table :reproduction_samples do |t|
      t.text :en
      t.text :ch
      t.references :reproduction_question, index: true

      t.timestamps
    end
  end
end
