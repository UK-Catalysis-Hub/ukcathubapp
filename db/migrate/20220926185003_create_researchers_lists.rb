class CreateResearchersLists < ActiveRecord::Migration[6.1]
  def change
    create_view :researchers_lists
  end
end
