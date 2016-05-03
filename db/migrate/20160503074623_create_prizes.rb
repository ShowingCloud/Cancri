class CreatePrizes < ActiveRecord::Migration[5.0]
  def change
    create_table :prizes do |t|
      t.string :host_year, null: false
      t.string :name, null: false
      t.string :prize, null: false
      t.string :point, null: false
      t.string :desc
      t.boolean :status
      t.timestamps
    end
    add_index :prizes, :host_year
    add_index :prizes, [:name, :host_year, :prize], unique: true
    add_index :prizes, :prize
    add_index :prizes, :point
    add_index :prizes, :status
  end
end
