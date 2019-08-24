class CreateConsults < ActiveRecord::Migration[5.0]
  def change
    create_table :consults do |t|
      t.integer :user_id, null: false
      t.integer :parent_id
      t.string :content, null: false
      t.boolean :status, null: false, default: false
      t.boolean :unread, null: false, default: false
      t.boolean :admin_reply, null: false, default: false
      t.integer :admin_id
      t.timestamps
    end
    add_index :consults, :user_id
    add_index :consults, :parent_id
    add_index :consults, :status
    add_index :consults, :unread
    add_index :consults, :admin_reply
    add_index :consults, :admin_id
  end
end
