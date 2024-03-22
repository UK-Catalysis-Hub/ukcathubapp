class CreateListThemes < ActiveRecord::Migration[7.1]
  def change
    create_view :list_themes
  end
end
