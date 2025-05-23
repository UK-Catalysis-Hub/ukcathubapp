class CreateArticleAuthors < ActiveRecord::Migration[7.1]
  def change
    create_table :article_authors do |t|
      t.string :doi
      t.integer :author_id
      t.string :author_count
      t.integer :author_order
      t.string :status
      t.string :author_seq
      t.integer :article_id
      t.string :orcid
      t.string :last_name
      t.string :given_name

      t.timestamps
    end
  end
end
