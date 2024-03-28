# This migration comes from xref_client (originally 20240327192229)
class CreateXrefClientMappings < ActiveRecord::Migration[7.1]
  def change
    create_table :xref_client_mappings do |t|
      t.string :obj_name
      t.string :origin
      t.string :target
      t.string :target_type
      t.string :default
      t.string :json_paths
      t.string :evaluate
      t.string :other

      t.timestamps
    end
  end
end
