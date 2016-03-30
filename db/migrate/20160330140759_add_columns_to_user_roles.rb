class AddColumnsToUserRoles < ActiveRecord::Migration[5.0]
  def change
    add_column :user_roles, :status, :boolean, null: false, default: false
    add_index :user_roles, :status
  end
end
