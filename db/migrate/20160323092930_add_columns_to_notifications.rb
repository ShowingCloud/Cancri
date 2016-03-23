class AddColumnsToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :t_u_id, :integer
    add_index :notifications, :t_u_id
    add_index :notifications, :team_id
  end
end
