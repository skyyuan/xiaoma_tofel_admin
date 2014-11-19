class AddContentChToReproductionQuestion < ActiveRecord::Migration
  def change
    add_column :reproduction_questions, :content_ch, :text
  end
end
