class CreateCompetitionSchedules < ActiveRecord::Migration[5.0]
  def change
    create_table :competition_schedules do |t|
      t.integer :competition_id, null: false
      t.string :name, null: false
      t.datetime :start_time
      t.datetime :end_time
      t.timestamps
    end
    add_index :competition_schedules, :competition_id
  end
end
