class ChangeNameForCrAffiliationAffiliationId < ActiveRecord::Migration[6.0]
  def change
    rename_column :cr_affiliations, :affiliation_id, :author_affiliation_id
  end
end
