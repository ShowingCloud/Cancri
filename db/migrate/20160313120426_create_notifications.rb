class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.text :content
      t.string :message_type
      t.boolean :read, default: false

      t.timestamps
    end
    add_index :notifications, :user_id
    add_index :notifications, :read
    add_index :notifications, :message_type
  end
end
