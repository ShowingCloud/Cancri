class AddColumnsToTables < ActiveRecord::Migration[5.0]
  def change
    add_column :event_schedules, :group, :integer, null: false
    remove_index :event_schedules, [:event_id, :schedule_id]
    add_index :event_schedules, [:event_id, :schedule_id, :group], unique: true, name: 'index_event_schedules'
    add_column :news, :desc, :text
    add_column :volunteers, :cover, :string
    add_column :volunteers, :desc, :text
    add_column :competitions, :time_schedule, :string
    add_column :competitions, :detail_rule, :string
  end
end
