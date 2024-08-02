class CreateArticles < ActiveRecord::Migration[7.1]
  def change
    create_table :articles do |t|
      t.string :doi
      t.string :title
      t.integer :pub_year
      t.string :pub_type
      t.string :publisher
      t.string :container_title
      t.string :volume
      t.string :issue
      t.string :page
      t.integer :pub_print_year
      t.integer :pub_print_month
      t.integer :pub_print_day
      t.integer :pub_ol_year
      t.integer :pub_ol_month
      t.integer :pub_ol_day
      t.string :license
      t.integer :referenced_by_count
      t.string :link
      t.string :url
      t.text :abstract
      t.string :status
      t.string :comment
      t.integer :references_count
      t.string :journal_issue

      t.timestamps
    end
  end
end
