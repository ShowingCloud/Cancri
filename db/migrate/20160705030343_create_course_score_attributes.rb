class CreateCourseScoreAttributes < ActiveRecord::Migration[5.0]
  def change
    create_table :course_score_attributes do |t|
      t.integer :course_id, null: false
      t.string :name, null: false
      t.integer :score_per, null: false

      t.timestamps
    end
    add_index :course_score_attributes, :course_id
    add_index :course_score_attributes, [:course_id, :name], unique: true, name: 'index_course_score_attributes'
    add_index :course_score_attributes, :score_per
  end
end
