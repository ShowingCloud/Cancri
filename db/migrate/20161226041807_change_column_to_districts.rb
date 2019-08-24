class ChangeColumnToDistricts < ActiveRecord::Migration[5.0]
  def change
    remove_index :districts, :name
    remove_index :districts, :city
    remove_index :districts, [:name, :city]
    remove_column :districts, :city
    add_column :districts, :city_id, :integer, null: false, default: 1
    add_column :districts, :province_name, :string, null: false, default: '上海市'
    add_column :districts, :city_name, :string, null: false, default: '上海市'
    add_column :districts, :pinyin, :string, limit: 50
    add_column :districts, :abbr, :string, limit: 20
    add_index :districts, [:name, :city_id], unique: true
    add_index :districts, :province_name
    add_index :districts, :city_id
  end
end
