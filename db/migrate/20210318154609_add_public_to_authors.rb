class AddPublicToAuthors < ActiveRecord::Migration[6.0]
  def change
    add_column :authors, :is_public, :boolean
  end
end
