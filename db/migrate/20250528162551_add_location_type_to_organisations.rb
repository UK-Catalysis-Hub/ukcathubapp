class AddLocationTypeToOrganisations < ActiveRecord::Migration[7.1]
  def change
    add_column :organisations, :sector, :string
  end
end
