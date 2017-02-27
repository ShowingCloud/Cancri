class AddColumnsToEventVolunteers < ActiveRecord::Migration[5.0]
  def change
    add_column :event_volunteers, :positions, :json
    add_column :user_roles, :times, :integer, null: false, default: 0
    add_column :user_roles, :points, :decimal, null: false, default: 0
    add_column :event_volunteer_users, :event_id, :integer
    change_column :event_volunteer_users, :position, :integer
  end
end
