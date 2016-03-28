class AddColumnsToEventSaShips < ActiveRecord::Migration[5.0]
  def change
    add_column :event_sa_ships, :desc, :string
  end
end
