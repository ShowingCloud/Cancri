class CreateUserPoints < ActiveRecord::Migration[5.0]
  def change
    create_table :user_points do |t|
      t.integer :prize_id
      t.integer :user_id
      t.string :cover
      t.boolean :status
      t.boolean :is_audit, null: false, default: false

      t.timestamps
    end
    add_index :user_points, :prize_id
    add_index :user_points, :user_id
    add_index :user_points, :status
    add_index :user_points, :is_audit
  end
end
