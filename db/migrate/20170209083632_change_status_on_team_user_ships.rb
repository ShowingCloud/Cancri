class ChangeStatusOnTeamUserShips < ActiveRecord::Migration[5.0]
  def change
    change_column :team_user_ships, :status, :integer, :using => 'case when status then 1 else 0 end'
  end
end
