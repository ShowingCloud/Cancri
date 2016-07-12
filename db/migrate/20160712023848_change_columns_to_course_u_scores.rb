class ChangeColumnsToCourseUScores < ActiveRecord::Migration[5.0]
  def change
    remove_index :course_user_scores, :user_id
    remove_index :course_user_scores, :course_id
    remove_index :course_user_scores, [:course_id, :user_id]
    remove_index :course_user_scores, [:course_id, :user_id, :course_sa_id]
    remove_column :course_user_scores, :course_id
    remove_column :course_user_scores, :user_id
  end
end
