class AddCutDateToCrPublications < ActiveRecord::Migration[7.1]
  def change
    add_column :cr_publications, :cut_date, :datetime
  end
end
