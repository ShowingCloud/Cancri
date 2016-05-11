class CreateEventSchedules < ActiveRecord::Migration[5.0]
  def change
    create_table :event_schedules do |t|
      t.integer :event_id
      t.integer :schedule_id
      t.integer :kind, null: false, default: 1
      t.timestamps
    end
    add_index :event_schedules, :event_id
    add_index :event_schedules, :schedule_id
    add_index :event_schedules, [:event_id, :schedule_id], unique: true, name: 'index_event_schedules'
    add_index :event_schedules, :kind
    remove_column :scores, :schedule_name
    remove_index :scores, :schedule_name
    add_column :scores, :schedule_id
    add_index :scores, :schedule_id
  end
end
