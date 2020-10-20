class CreateListThemes < ActiveRecord::Migration[6.0]
  def change
    create_view :list_themes
  end
end
