class AddGraphabstToArticles < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :graphic_abstract, :string
  end
end
