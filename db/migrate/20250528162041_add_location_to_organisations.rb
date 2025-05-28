class AddLocationToOrganisations < ActiveRecord::Migration[7.1]
  def change
    add_column :organisations, :country, :string
    add_column :organisations, :city, :string
  end
end
