class CreateAuthors < ActiveRecord::Migration[6.0]
  def change
    create_table :authors do |t|
      t.string :full_name
      t.string :last_name
      t.string :given_name
      t.string :orcid
      t.string :articles

      t.timestamps
    end
  end
end
