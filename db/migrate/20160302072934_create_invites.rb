class CreateInvites < ActiveRecord::Migration[5.0]
  def change
    create_table :invites do |t|
      t.integer :user_id
      t.string :email
      t.string :code
      t.string :invite_type
      t.integer :team_id
      t.timestamps
    end

    add_index :invites, :code, unique: true
    add_index :invites, :user_id
    add_index :invites, :email
    add_index :invites, :invite_type
    add_index :invites, :team_id
    add_index :invites, [:email, :team_id, :user_id], unique: true
  end
end
