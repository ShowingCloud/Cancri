class CreateCourseFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :course_files do |t|
      t.integer :course_id, null: false
      t.string :course_ware
      t.boolean :status

      t.timestamps
    end
    add_index :course_files, :course_id
    add_index :course_files, :status

  end
end
