class AddScheduleIdToEventSaShips < ActiveRecord::Migration[5.0]
  def change
    add_column :event_sa_ships, :schedule_id, :integer, null: false, default: 1
    add_index :event_sa_ships, [:event_id, :schedule_id]
    remove_index :event_sa_ships, [:event_id, :score_attribute_id, :parent_id]
  end
end
