class AddColumnsToTeamUserShips < ActiveRecord::Migration[5.0]
  def change
    add_column :team_user_ships, :status, :boolean, default: true, null: false
    add_index :team_user_ships, :status
  end
end
