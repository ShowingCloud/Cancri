class CreateEventVolPositions < ActiveRecord::Migration[5.0]
  def change
    create_table :event_vol_positions do |t|
      t.integer :event_volunteer_id, null: false
      t.string :name, null: false, limit: 50
      t.boolean :status, null: false, default: true

      t.timestamps
    end
    add_index :event_vol_positions, :event_volunteer_id
    add_index :event_vol_positions, [:event_volunteer_id, :name], unique: true, name: 'index_on_event_vol_positions'
  end
end
