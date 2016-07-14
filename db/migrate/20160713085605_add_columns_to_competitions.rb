class AddColumnsToCompetitions < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :time_schedule, :string
    add_column :competitions, :detail_rule, :string
  end
end
