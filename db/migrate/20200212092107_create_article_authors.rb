class CreateArticleAuthors < ActiveRecord::Migration[6.0]
  def change
    create_table :article_authors do |t|
      t.string :doi
      t.integer :author_id
      t.string :author_count
      t.integer :author_order
      t.string :status
      t.string :sequence
      t.integer :article_id

      t.timestamps
    end
  end
end
