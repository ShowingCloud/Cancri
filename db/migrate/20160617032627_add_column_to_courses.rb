class AddColumnToCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :apply_count, :integer, null: false, default: 0
    add_index :courses, :apply_count
  end
end
