class AddSchoolToAffiliations < ActiveRecord::Migration[6.0]
  def change
    add_column :affiliations, :school, :string
  end
end
