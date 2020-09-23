class ChangeNameForauthorAffiliationAuthorId < ActiveRecord::Migration[6.0]
  def change
    rename_column :author_affiliations, :author_id, :article_author_id
  end
end
