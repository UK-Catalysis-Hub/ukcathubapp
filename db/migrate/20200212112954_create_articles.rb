class CreateArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :articles do |t|
      t.integer :reference_count
      t.string :publisher
      t.string :issue
      t.string :license
      t.integer :pub_print_year
      t.integer :pub_print_month
      t.integer :pub_print_day
      t.string :doi
      t.string :pub_type
      t.string :page
      t.string :title
      t.string :volume
      t.integer :pub_ol_year
      t.integer :pub_ol_month
      t.integer :pub_ol_day
      t.string :container_title
      t.string :link
      t.string :references_count
      t.string :journal_issue
      t.string :url
      t.string :abstract
      t.string :status
      t.string :comment

      t.timestamps
    end
  end
end
