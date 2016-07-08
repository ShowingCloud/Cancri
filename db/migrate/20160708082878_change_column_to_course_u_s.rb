class ChangeColumnToCourseUS < ActiveRecord::Migration[5.0]
  def change
    add_column :course_user_scores, :course_user_ship_id, :integer
    add_index :course_user_scores, :course_user_ship_id
  end
end
