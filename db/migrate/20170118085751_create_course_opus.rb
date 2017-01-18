class CreateCourseOpus < ActiveRecord::Migration[5.0]
  def change
    create_table :course_opus do |t|
      t.integer :course_user_ship_id, null: false
      t.integer :status, null: false, default: 0
      t.string :name, null: false
      t.string :desc

      t.timestamps
    end
    add_index :course_opus, :course_user_ship_id
    add_index :course_opus, :status
  end
end
