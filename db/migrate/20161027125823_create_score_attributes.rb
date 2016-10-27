class CreateScoreAttributes < ActiveRecord::Migration[5.0]
  def change
    create_table :score_attributes do |t|
      t.string :name, null: false, limit: 50
      t.integer :write_type
      t.string :desc

      t.timestamps
    end
    add_index :score_attributes, [:name, :write_type], unique: true
  end
end
