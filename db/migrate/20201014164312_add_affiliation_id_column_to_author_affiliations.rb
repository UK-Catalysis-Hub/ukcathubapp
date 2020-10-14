class AddAffiliationIdColumnToAuthorAffiliations < ActiveRecord::Migration[6.0]
  def change
    add_column :author_affiliations, :affiliation_id, :integer
  end
end
