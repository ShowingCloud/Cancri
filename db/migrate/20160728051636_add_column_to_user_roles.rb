class AddColumnToUserRoles < ActiveRecord::Migration[5.0]
  def change
    add_column :user_roles, :school_id, :integer
    add_column :user_roles, :district_id, :integer
    add_index :user_roles, :school_id
    add_index :user_roles, :district_id
  end
end
