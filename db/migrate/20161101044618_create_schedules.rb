class CreateSchedules < ActiveRecord::Migration[5.0]
  def change
    create_table :schedules do |t|
      t.string :name, limit: 30, null: false
      t.integer :sort

      t.timestamps
    end
    add_index :schedules, :name, unique: true
  end
end
