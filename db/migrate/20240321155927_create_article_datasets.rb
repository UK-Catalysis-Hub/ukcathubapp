class CreateArticleDatasets < ActiveRecord::Migration[7.1]
  def change
    create_table :article_datasets do |t|
      t.string :doi
      t.integer :article_id
      t.integer :dataset_id

      t.timestamps
    end
  end
end
