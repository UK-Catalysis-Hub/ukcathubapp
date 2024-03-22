class CreateAffiliations < ActiveRecord::Migration[7.1]
  def change
    create_table :affiliations do |t|
      t.string :institution
      t.string :department
      t.string :faculty
      t.string :school
      t.string :work_group
      t.string :country
      t.string :sector

      t.timestamps
    end
  end
end
