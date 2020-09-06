class ChangeNameForReferenceCount < ActiveRecord::Migration[6.0]
  def change
    rename_column :articles, :reference_count, :referenced_by_count
  end
end
