class AddColumnToTu < ActiveRecord::Migration[5.0]
  def change
    add_column :team_user_ships, :school_id, :integer
    add_column :team_user_ships, :district_id, :integer
    add_column :team_user_ships, :grade, :string
    add_index :team_user_ships, :school_id
    add_index :team_user_ships, :grade
    add_index :team_user_ships, :district_id
  end
end
