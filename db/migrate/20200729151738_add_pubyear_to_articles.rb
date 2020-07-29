class AddPubyearToArticles < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :pub_year, :integer
  end
end
