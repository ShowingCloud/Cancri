class CreateCourses < ActiveRecord::Migration[5.0]
  def change
    create_table :courses do |t|
      t.string :name, null: false
      t.string :target, null: false
      t.text :desc
      t.integer :num, null: false
      t.datetime :apply_start_time, null: false
      t.datetime :apply_end_time, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.string :run_time, null: false
      t.integer :status, null: false, default: 0
      t.integer :user_id
      t.string :keyword

      t.timestamps
    end
    add_index :courses, :name, unique: true
    add_index :courses, :apply_start_time
    add_index :courses, :apply_end_time
    add_index :courses, :num
    add_index :courses, :status
    add_index :courses, :user_id
  end
end
