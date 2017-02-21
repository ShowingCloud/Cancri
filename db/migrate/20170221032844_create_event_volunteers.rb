class CreateEventVolunteers < ActiveRecord::Migration[5.0]
  def change
    create_table :event_volunteers do |t|
      t.string :name, limit: 100
      t.string :event_type, null: false
      t.integer :type_id, null: false
      t.text :content, null: false
      t.datetime :apply_start_time, null: false
      t.datetime :apply_end_time, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
    add_index :event_volunteers, :status
  end
end
