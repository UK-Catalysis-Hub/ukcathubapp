class CreateAuthorCollaborations < ActiveRecord::Migration[8.1]
  def change
    create_view :author_collaborations
  end
end
