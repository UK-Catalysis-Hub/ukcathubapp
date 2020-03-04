class CreateDatasets < ActiveRecord::Migration[6.0]
  def change
    create_table :datasets do |t|
      t.string :dataset_complete
      t.string :dataset_description
      t.string :dataset_doi
      t.string :dataset_enddate
      t.string :dataset_location
      t.string :dataset_name
      t.string :dataset_startdate

      t.timestamps
    end
  end
end
