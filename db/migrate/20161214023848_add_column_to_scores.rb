class AddColumnToScores < ActiveRecord::Migration[5.0]
  def change
    add_column :scores, :sort_score, :decimal, precision: 10, scale: 2, default: 0.00
    add_column :scores, :operate_score, :decimal, precision: 10, scale: 2, default: 0.00
  end
end
