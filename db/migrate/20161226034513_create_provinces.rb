class CreateProvinces < ActiveRecord::Migration[5.0]
  def change
    create_table :provinces do |t|
      t.string :name, limit: 50, null: false
      t.string :pinyin, limit: 50
      t.string :abbr, limit: 50
      t.integer :sort

      t.timestamps
    end
    add_index :provinces, :name, unique: true
  end
end
