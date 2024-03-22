class AddPdffileToArticles < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :pdf_file, :string
  end
end
