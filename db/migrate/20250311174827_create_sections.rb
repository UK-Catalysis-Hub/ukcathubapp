class CreateSections < ActiveRecord::Migration[7.1]
  def change
    create_table :sections do |t|
      t.string :obj_name
      t.string :name
      t.string :heading
      t.string :description
      t.boolean :visible

      t.timestamps
    end
  end
end
