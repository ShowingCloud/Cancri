class ChangeColumnToTeams < ActiveRecord::Migration[5.0]
  def change
    change_column :teams, :identifier, :string
  end
end
