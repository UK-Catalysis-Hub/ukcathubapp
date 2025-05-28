class AddOrganisationToAffiliations < ActiveRecord::Migration[7.1]
  def change
    add_column :affiliations, :organisation_id, :integer
  end
end
