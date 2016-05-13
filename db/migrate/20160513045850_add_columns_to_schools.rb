class AddColumnsToSchools < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :status, :boolean, null: false, default: 1
    add_column :schools, :audit, :boolean
    add_index :schools, :status
    add_index :schools, :audit
  end
end
