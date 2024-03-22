class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.string :add_01
      t.string :add_02
      t.string :add_03
      t.string :add_04
      t.string :city
      t.string :province
      t.string :country
      t.integer :affiliation_id

      t.timestamps
    end
  end
end
