class ChangeColumnsToSchools < ActiveRecord::Migration[5.0]
  def change
    change_column :schools, :school_type, :integer, null: true
    remove_index :schools, [:district_id, :school_type, :name]
    remove_index :schools, :name
    add_index :schools, :name, unique: true
  end
end
