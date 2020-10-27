class AddDsTypeAndRepositoryColumnsToDatasets < ActiveRecord::Migration[6.0]
  def change
    add_column :datasets, :ds_type, :string
    add_column :datasets, :repository, :string
  end
end
