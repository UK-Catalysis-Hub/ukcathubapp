class CreateAffiliations < ActiveRecord::Migration[6.0]
  def change
    create_table :affiliations do |t|
      t.string :institution
      t.string :department
      t.string :faculty
      t.string :work_group
      t.string :country

      t.timestamps
    end
  end
end
