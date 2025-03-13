class CreateAppConfigs < ActiveRecord::Migration[7.1]
  def change
    create_table :app_configs do |t|
      t.string :title
      t.string :broser_tab_name
      t.string :favicon
      t.string :logo
      t.integer :organisation_id
      t.integer :contact_id
      t.string :contact_email
      t.string :award_list
      t.string :synon_list

      t.timestamps
    end
  end
end
