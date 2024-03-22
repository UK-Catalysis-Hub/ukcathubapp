class CreateDatasets < ActiveRecord::Migration[7.1]
  def change
    create_table :datasets do |t|
      t.string :complete
      t.string :description
      t.string :doi
      t.datetime :enddate
      t.string :location
      t.string :name
      t.datetime :startdate
      t.string :ds_type
      t.string :repository

      t.timestamps
    end
  end
end
