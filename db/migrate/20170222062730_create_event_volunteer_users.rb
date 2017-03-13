class CreateEventVolunteerUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :event_volunteer_users do |t|
      t.integer :event_volunteer_id
      t.integer :user_id
      t.integer :status
      t.integer :point
      t.string :desc
      t.string :position
      t.timestamps
    end
    add_index :event_volunteer_users, :status
    add_index :event_volunteer_users, :user_id
    add_index :event_volunteer_users, [:user_id, :event_volunteer_id], unique: true, name: 'index_on_event_volunteer_users'
  end
end
