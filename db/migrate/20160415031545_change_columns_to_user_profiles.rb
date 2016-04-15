class ChangeColumnsToUserProfiles < ActiveRecord::Migration[5.0]
  def change
    change_column :user_profiles, :school, :integer
    change_column :user_profiles, :district, :integer
    add_column :schools, :user_add, :boolean, null: false, default: false
    add_column :schools, :user_id, :integer
    add_index :schools, :user_add
    add_index :schools, :user_id
  end
end
