class ChangeColumnToMedia < ActiveRecord::Migration[5.0]
  def change
    change_column :photos, :status, :boolean, default: false
    change_column :videos, :status, :boolean, default: false
  end
end
