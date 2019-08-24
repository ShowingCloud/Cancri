class CreateTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :teams do |t|
      t.string :name
      t.integer :user_id
      t.integer :group
      t.integer :status
      t.boolean :audit
      t.string :identifier
      t.integer :event_id, null: false
      t.integer :school_id
      t.integer :sk_station
      t.integer :school1
      t.integer :district_id
      t.string :description
      t.string :teacher
      t.string :teacher_mobile
      t.string :team_code, limit: 6
      t.string :cover
      t.text :score_process
      t.string :last_score
      t.string :referee_id
      t.integer :rank
      t.text :note

      t.timestamps
    end

    add_index :teams, :name
    add_index :teams, :event_id
    add_index :teams, [:event_id, :name], unique: true
    add_index :teams, [:event_id, :user_id], unique: true
    add_index :teams, :team_code
    add_index :teams, :user_id
    add_index :teams, :teacher
    add_index :teams, :district_id
    add_index :teams, :identifier, unique: true

  end
end
