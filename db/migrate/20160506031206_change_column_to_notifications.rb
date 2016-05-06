class ChangeColumnToNotifications < ActiveRecord::Migration[5.0]
  def change
    change_column :notifications, :message_type, :integer, null: false, default: 0
  end
end
