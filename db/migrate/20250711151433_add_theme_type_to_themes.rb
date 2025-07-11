class AddThemeTypeToThemes < ActiveRecord::Migration[7.1]
  def change
    add_column :themes, :theme_type, :string
  end
end
