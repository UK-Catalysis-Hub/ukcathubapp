class UpdateResearchersListsToVersion2 < ActiveRecord::Migration[6.1]
  def change
    update_view :researchers_lists, version: 2, revert_to_version: 1
  end
end
