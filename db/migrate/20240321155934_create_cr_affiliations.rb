class CreateCrAffiliations < ActiveRecord::Migration[7.1]
  def change
    create_table :cr_affiliations do |t|
      t.string :name
      t.string :article_author_id
      t.string :author_affiliation_id

      t.timestamps
    end
  end
end
