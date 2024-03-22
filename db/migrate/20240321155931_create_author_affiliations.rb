class CreateAuthorAffiliations < ActiveRecord::Migration[7.1]
  def change
    create_table :author_affiliations do |t|
      t.integer :article_author_id
      t.string :name
      t.string :short_name
      t.string :add_01
      t.string :add_02
      t.string :add_03
      t.string :add_04
      t.string :add_05
      t.string :city
      t.string :province
      t.string :country
      t.integer :affiliation_id

      t.timestamps
    end
  end
end
