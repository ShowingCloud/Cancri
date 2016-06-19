class AddColumnsToUserRoles < ActiveRecord::Migration[5.0]
  def change
    add_column :user_roles, :desc, :text
    add_column :user_roles, :cover, :string
  end
end
