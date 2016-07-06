class CreateCourseUserScores < ActiveRecord::Migration[5.0]
  def change
    create_table :course_user_scores do |t|
      t.integer :course_id, null: false
      t.integer :user_id, null: false
      t.integer :course_sa_id, null: false
      t.string :score, null: false
      t.timestamps
    end
    add_index :course_user_scores, :course_id
    add_index :course_user_scores, :user_id
    add_index :course_user_scores, [:course_id, :user_id]
    add_index :course_user_scores, :course_sa_id
    add_index :course_user_scores, [:course_id, :user_id, :course_sa_id], unique: true, name: 'index_course_user_scores'
  end
end
