class AddCoverToCourseOpus < ActiveRecord::Migration[5.0]
  def change
    add_column :course_opus, :cover, :string, null: false
  end
end
