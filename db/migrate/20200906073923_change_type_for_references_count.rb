class ChangeTypeForReferencesCount < ActiveRecord::Migration[6.0]
  def change
    change_column :articles, :references_count, :integer
  end
end
