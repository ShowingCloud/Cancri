class AddColumnsToScores < ActiveRecord::Migration[5.0]
  def change
    add_column :scores, :device_no, :string
    add_index :scores, :device_no
  end
end
