class AddColumnToCourseUShips < ActiveRecord::Migration[5.0]
  def change
    add_column :course_user_ships, :score, :string
    add_index :course_user_ships, :score
  end
end
