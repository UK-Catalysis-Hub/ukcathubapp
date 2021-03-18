class AddIsApprovToAuthors < ActiveRecord::Migration[6.0]
  def change
    add_column :authors, :isap, :boolean
  end
end
