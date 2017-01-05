class AddColumnToUserFamilyHacker < ActiveRecord::Migration[5.0]
  def change
    add_column :user_families, :user_role_id, :integer, null: false
    add_column :user_hackers, :user_role_id, :integer, null: false
    add_column :user_profiles, :position, :string
  end
end
