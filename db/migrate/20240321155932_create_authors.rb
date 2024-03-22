class CreateAuthors < ActiveRecord::Migration[7.1]
  def change
    create_table :authors do |t|
      t.string :last_name
      t.string :given_name
      t.string :orcid
      t.boolean :isap

      t.timestamps
    end
  end
end
