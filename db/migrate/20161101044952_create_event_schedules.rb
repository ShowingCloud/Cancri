class CreateEventSchedules < ActiveRecord::Migration[5.0]
  def change
    create_table :event_schedules do |t|
      t.integer :event_id, null: false
      t.integer :schedule_id, null: false
      t.integer :group, null: false
      t.integer :kind, null: false
      t.timestamps
    end
    add_index :event_schedules, :event_id
    add_index :event_schedules, :schedule_id
    add_index :event_schedules, [:event_id, :schedule_id, :group], unique: true, name: 'index_event_schedules'
  end
end
