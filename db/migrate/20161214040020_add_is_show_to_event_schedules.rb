class AddIsShowToEventSchedules < ActiveRecord::Migration[5.0]
  def change
    add_column :event_schedules, :is_show, :boolean, default: true, null: false
  end
end
