class AddColumnToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :players, :integer, null: false, default: 0
    add_index :teams, :players
  end
end
