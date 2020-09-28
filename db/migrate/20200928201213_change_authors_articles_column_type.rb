class ChangeAuthorsArticlesColumnType < ActiveRecord::Migration[6.0]
  def change
    change_column :authors, :articles, :integer
  end
end
