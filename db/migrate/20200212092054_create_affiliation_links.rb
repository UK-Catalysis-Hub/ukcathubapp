class CreateAffiliationLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :affiliation_links do |t|
      t.integer :affiliation_id
      t.string :doi
      t.integer :author_id
      t.string :sequence
      t.integer :address_id

      t.timestamps
    end
  end
end
