class AddColumnSectorToAffiliation < ActiveRecord::Migration[6.0]
  def change
    add_column :affiliations, :sector, :string
  end
end
