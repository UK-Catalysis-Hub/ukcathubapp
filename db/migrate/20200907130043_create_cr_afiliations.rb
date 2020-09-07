class CreateCrAfiliations < ActiveRecord::Migration[6.0]
  def change
    create_table :cr_afiliations do |t|
      t.string :name
      t.integer :article_author_id
      t.integer :affiliation_id

      t.timestamps
    end
  end
end
