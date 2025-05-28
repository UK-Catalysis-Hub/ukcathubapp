class AddRegionToOrganisations < ActiveRecord::Migration[7.1]
  def change
    add_column :organisations, :region, :string
  end
end
