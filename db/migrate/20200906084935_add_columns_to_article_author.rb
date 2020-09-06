class AddColumnsToArticleAuthor < ActiveRecord::Migration[6.0]
  def change
    add_column :article_authors, :orcid, :string
    add_column :article_authors, :last_name, :string
    add_column :article_authors, :given_name, :string
  end
end
