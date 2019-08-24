class AddColumnsToTables < ActiveRecord::Migration[5.0]
  def change
    add_column :scores, :created_at, :datetime, null: false, default: Time.zone.now
    add_column :scores, :updated_at, :datetime, null: false, default: Time.zone.now
  end
end
