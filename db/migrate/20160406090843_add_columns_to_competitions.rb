class AddColumnsToCompetitions < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :host_year, :string, null: false
    add_column :competitions, :emc_contact, :string
    add_index :competitions, :host_year
  end
end
