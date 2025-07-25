class CreateOrganisationAliases < ActiveRecord::Migration[7.1]
  def change
    create_table :organisation_aliases do |t|
      t.integer :organisation_id
      t.string :name
      t.string :alias_type
      t.datetime :valid_from
      t.datetime :valid_to
      t.string :laguage_code

      t.timestamps
    end
  end
end
