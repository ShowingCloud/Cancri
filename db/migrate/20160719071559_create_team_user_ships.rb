class CreateTeamUserShips < ActiveRecord::Migration[5.0]
  def change
    create_table :team_user_ships do |t|
      t.integer :team_id, null: false
      t.integer :user_id, null: false
      t.integer :event_id
      t.integer :district_id
      t.integer :school_id, null: false
      t.integer :grade
      t.boolean :status
      t.string :num
      t.timestamps
    end
    add_index :team_user_ships, :team_id
    add_index :team_user_ships, :user_id
    add_index :team_user_ships, :event_id
    add_index :team_user_ships, [:team_id, :user_id], unique: true
    add_index :team_user_ships, [:event_id, :user_id], unique: true
    add_index :team_user_ships, [:event_id, :team_id, :user_id], unique: true
    add_index :team_user_ships, :school_id
    add_index :team_user_ships, :district_id
    add_index :team_user_ships, :status
    add_index :team_user_ships, :num
  end
end
