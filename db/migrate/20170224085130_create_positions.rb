class CreatePositions < ActiveRecord::Migration[5.0]
  def change
    create_table :positions do |t|
      t.string :name, limit: 50, null: false
      t.integer :sort, null: false, default: 1
      t.boolean :status, null: false, default: true
      t.string :desc
      t.timestamps
    end
    add_index :positions, :name, unique: true
  end
end
