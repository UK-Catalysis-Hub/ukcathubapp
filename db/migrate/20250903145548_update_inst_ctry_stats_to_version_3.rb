class UpdateInstCtryStatsToVersion3 < ActiveRecord::Migration[7.1]
  def change
    update_view :inst_ctry_stats, version: 3, revert_to_version: 2
  end
end
