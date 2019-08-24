class CreateUserRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :user_roles do |t|
      t.integer :user_id
      t.integer :role_id
      t.integer :status # 0 待审核, 1 通过
      t.integer :role_type # {role_id:1,role_type:{1:市级; 2:区级（唯一）; 3:校级（唯一）; 4:区级; 5:校级; 6:外聘}}
      t.timestamps
    end

    add_index :user_roles, :user_id
    add_index :user_roles, :role_id
    add_index :user_roles, [:user_id, :role_id, :role_type], unique: true
    add_index :user_roles, [:user_id, :role_id]
    add_index :user_roles, :status
    add_index :user_roles, :role_type
  end
end
