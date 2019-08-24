class AddColumnsToActivities < ActiveRecord::Migration[5.0]
  def change
    change_column :activities, :status, :integer, default: 0, null: false
    add_column :activities, :is_father, :boolean, default: false, null: false
    add_column :activities, :parent_id, :integer
    add_column :activities, :level, :integer, default: 1, null: false
    add_index :activities, :is_father
    add_index :activities, :parent_id
  end
end
