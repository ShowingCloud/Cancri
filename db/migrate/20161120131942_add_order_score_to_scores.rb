class AddOrderScoreToScores < ActiveRecord::Migration[5.0]
  def change
    add_column :scores, :order_score, :decimal, precision: 10, scale: 2, default: 0.00
  end
end
