class CreateCities < ActiveRecord::Migration[5.0]
  def change
    create_table :cities do |t|
      t.string :name, limit: 50, null: false
      t.integer :province_id, null: false
      t.string :pinyin
      t.string :abbr
      t.integer :sort

      t.timestamps
    end
    add_index :cities, [:province_id, :name], unique: true
  end
end
