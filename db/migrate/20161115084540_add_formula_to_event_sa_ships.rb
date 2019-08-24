class AddFormulaToEventSaShips < ActiveRecord::Migration[5.0]
  def change
    add_column :event_sa_ships, :formula, :json
  end
end
