class AddPdfFileToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :pdf_file, :string
  end
end
