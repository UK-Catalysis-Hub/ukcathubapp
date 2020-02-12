class CreateArticleThemes < ActiveRecord::Migration[6.0]
  def change
    create_table :article_themes do |t|
      t.string :doi
      t.integer :phase
      t.string :collaboration
      t.integer :theme_id
      t.integer :project_year

      t.timestamps
    end
  end
end
