class CreateOrganisations < ActiveRecord::Migration[7.1]
  def change
    create_table :organisations do |t|
      t.string :name
      t.string :short_name
      t.string :identifier
      t.string :logo
      t.string :homepage
      t.integer :address_id

      t.timestamps
    end
  end
end
