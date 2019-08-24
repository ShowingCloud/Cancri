class CreateScores < ActiveRecord::Migration[5.0]
  def change
    create_table :scores do |t|
      t.integer :event_id, null: false
      t.integer :schedule_id, null: false
      t.integer :kind, null: false
      t.integer :th, null: false, default: 1
      t.integer :team1_id, null: false
      t.integer :team2_id
      t.json :score_attribute
      t.string :score1, null: false
      t.string :score2
      t.boolean :last_score, null: false, default: false
      t.decimal :score, precision: 10, scale: 2
      t.string :confirm_sign
      t.string :device_no
      t.integer :user_id
      t.text :note
    end
    add_index :scores, [:event_id, :schedule_id]
    add_index :scores, [:event_id, :schedule_id, :team1_id], name: 'index_on_scores'
    add_index :scores, :team1_id
  end
end
