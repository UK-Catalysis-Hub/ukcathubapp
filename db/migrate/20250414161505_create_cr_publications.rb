class CreateCrPublications < ActiveRecord::Migration[7.1]
  def change
    create_table :cr_publications do |t|
      t.string :authors
      t.integer :pub_year
      t.string :title
      t.string :doi
      t.string :awards
      t.string :xref_affi
      t.string :themes
      t.integer :status
      t.string :note

      t.timestamps
    end
  end
end
