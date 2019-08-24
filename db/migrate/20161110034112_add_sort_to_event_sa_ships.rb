class AddSortToEventSaShips < ActiveRecord::Migration[5.0]
  def change
    add_column :event_sa_ships, :sort, :integer, null: false, default: 1
  end
end
