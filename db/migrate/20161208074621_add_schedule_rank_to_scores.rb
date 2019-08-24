class AddScheduleRankToScores < ActiveRecord::Migration[5.0]
  def change
    add_column :scores, :schedule_rank, :integer
  end
end
