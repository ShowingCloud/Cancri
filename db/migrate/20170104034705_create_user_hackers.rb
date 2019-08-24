class CreateUserHackers < ActiveRecord::Migration[5.0]
  def change
    create_table :user_hackers do |t|
      t.integer :user_id, null: false
      t.date :create_date
      t.decimal :square
      t.integer :situation # 1:工作间, 2:工作台
      t.integer :partake
      t.string :active_weekly
      t.string :family_hobbies
      t.integer :create_way
      t.string :create_with

      t.timestamps
    end
    add_index :user_hackers, :user_id
  end
end
