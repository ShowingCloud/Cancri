class CreateCourseUserShips < ActiveRecord::Migration[5.0]
  def change
    create_table :course_user_ships do |t|
      t.integer :course_id, null: false
      t.integer :user_id, null: false
      t.integer :status, null: false, default: 0
      t.integer :school_id, null: false
      t.integer :grade, null: false
      t.timestamps
    end
    add_index :course_user_ships, :course_id
    add_index :course_user_ships, :user_id
    add_index :course_user_ships, [:course_id, :user_id], unique: true
    add_index :course_user_ships, :status
    add_index :course_user_ships, :school_id
    add_index :course_user_ships, :grade
  end
end
