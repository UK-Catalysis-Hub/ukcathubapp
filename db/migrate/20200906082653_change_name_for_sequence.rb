class ChangeNameForSequence < ActiveRecord::Migration[6.0]
  def change
    rename_column :article_authors, :sequence, :author_seq
  end
end
