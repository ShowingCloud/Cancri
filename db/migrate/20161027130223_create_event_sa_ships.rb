class CreateEventSaShips < ActiveRecord::Migration[5.0]
  def change
    create_table :event_sa_ships do |t|
      t.integer :event_id, null: false
      t.integer :score_attribute_id, null: false
      t.boolean :is_parent, null: false, default: false
      t.integer :parent_id
      t.integer :level, null: false, default: 1
      t.string :desc
      t.timestamps
    end
    add_index :event_sa_ships, :event_id
    add_index :event_sa_ships, :score_attribute_id
    add_index :event_sa_ships, [:event_id, :score_attribute_id, :parent_id], unique: true, name: 'index_event_sa_ships'
  end
end
