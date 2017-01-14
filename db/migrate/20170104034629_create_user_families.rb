class CreateUserFamilies < ActiveRecord::Migration[5.0]
  def change
    create_table :user_families do |t|
      t.integer :user_id, null: false
      t.string :father_name
      t.string :mother_name
      t.string :parent_mobile
      t.string :wx
      t.string :qq
      t.string :email
      t.string :address
      t.timestamps
    end
    add_index :user_families, :user_id
  end
end
