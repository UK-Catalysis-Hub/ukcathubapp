class CreateCrAffiliations < ActiveRecord::Migration[7.1]
  def change
    create_table :cr_affiliations do |t|
      t.string :name
      t.integer :article_author_id
      t.integer :author_affiliation_id

      t.timestamps
    end
  end
end
