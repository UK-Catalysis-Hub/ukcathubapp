class CreateInstCtryStats < ActiveRecord::Migration[7.1]
  def change
    create_view :inst_ctry_stats
  end
end
