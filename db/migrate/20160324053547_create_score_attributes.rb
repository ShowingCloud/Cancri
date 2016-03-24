class CreateScoreAttributes < ActiveRecord::Migration[5.0]
  def change
    create_table :score_attributes do |t|
      t.string :name, null: false, limit: 50
      t.timestamps
    end
    add_index :score_attributes, :name, unique: true
  end
end
