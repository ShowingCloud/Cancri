class ChangeColumnToScore < ActiveRecord::Migration[5.0]
  def change
    change_column :scores, :score1, :string, null: true
  end
end
