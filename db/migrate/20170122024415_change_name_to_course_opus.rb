class ChangeNameToCourseOpus < ActiveRecord::Migration[5.0]
  def change
    change_column :course_opus, :name, :string, null: true
  end
end
