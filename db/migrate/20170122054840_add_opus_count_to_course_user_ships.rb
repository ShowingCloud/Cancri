class AddOpusCountToCourseUserShips < ActiveRecord::Migration[5.0]
  def change
    add_column :course_user_ships, :opus_count, :integer, null: false, default: 0
  end
end
