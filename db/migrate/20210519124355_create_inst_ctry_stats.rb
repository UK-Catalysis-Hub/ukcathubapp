class CreateInstCtryStats < ActiveRecord::Migration[6.0]
  def change
    create_view :inst_ctry_stats
  end
end
