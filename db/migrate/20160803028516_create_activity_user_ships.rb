class CreateActivityUserShips < ActiveRecord::Migration[5.0]
  def change
    create_table :activity_user_ships do |t|
      t.integer :activity_id, null: false
      t.integer :user_id, null: false
      t.integer :school_id
      t.integer :grade
      t.boolean :status, null: false, default: 1
      t.boolean :has_join
      t.string :score

      t.timestamps
    end
    add_index :activity_user_ships, :user_id
    add_index :activity_user_ships, :activity_id
    add_index :activity_user_ships, [:user_id, :activity_id], unique: true, name: 'index_user_activity_ships'
    add_index :activity_user_ships, :status
    add_index :activity_user_ships, :has_join
  end
end
