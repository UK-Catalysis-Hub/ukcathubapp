class CreateThemes < ActiveRecord::Migration[7.1]
  def change
    create_table :themes do |t|
      t.string :short
      t.string :name
      t.string :lead
      t.integer :phase
      t.string :used

      t.timestamps
    end
  end
end
