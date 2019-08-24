class AddColumnToCourse < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :district_id, :integer, null: false
    add_index :courses, :district_id
  end
end
