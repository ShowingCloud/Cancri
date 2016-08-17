class AddDistrictToCompNewsActivity < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :district_id, :integer, null: false, default: 0
    add_column :activities, :district_id, :integer, null: false, default: 0
    add_column :news, :district_id, :integer, null: false, default: 0
    add_index :competitions, :district_id
    add_index :activities, :district_id
    add_index :news, :district_id
  end
end
