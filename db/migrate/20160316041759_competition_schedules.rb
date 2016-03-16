class CompetitionSchedules < ActiveRecord::Migration[5.0]
  def change
    create_table(:competition_schedules) do |t|
      t.integer :competition_id, null: false
      t.string :name, null: false
      t.string :start_time
      t.string :end_time
    end
    add_index :competition_schedules, :competition_id
    add_index :competition_schedules, :name
    add_index :competition_schedules, [:competition_id, :name]
  end
end
