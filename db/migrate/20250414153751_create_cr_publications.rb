class CreateCrPublications < ActiveRecord::Migration[7.1]
  def change
    create_table :cr_publications do |t|
      t.string :authors
      t.integer :pub_year
      t.string :title
      t.string :doi
      t.string :awards
      t.string :affiliation
      t.string :themes
      t.integer :status

      t.timestamps
    end
  end
end
