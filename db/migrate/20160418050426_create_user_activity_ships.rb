class CreateUserActivityShips < ActiveRecord::Migration[5.0]
  def change
    create_table :user_activity_ships do |t|
      t.integer :user_id, null: false
      t.integer :activity_id, null: false
      t.boolean :status
    end
    add_index :user_activity_ships, :user_id
    add_index :user_activity_ships, :activity_id
    add_index :user_activity_ships, [:user_id, :activity_id], unique: true, name: 'index_user_activity_ships'
    add_index :user_activity_ships, :status
  end
end
