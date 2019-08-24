class AddInRoundsToEventSaShips < ActiveRecord::Migration[5.0]
  def change
    add_column :event_sa_ships, :in_rounds, :boolean, default: true, null: false
  end
end
