class CreateCompWorkers < ActiveRecord::Migration[5.0]
  def change
    create_table :comp_workers do |t|
      t.integer :user_id, null: false
      t.integer :competition_id, null: false
      t.boolean :status
      t.integer :worker_type
    end
    add_index :comp_workers, :user_id
    add_index :comp_workers, :competition_id
    add_index :comp_workers, [:competition_id, :user_id, :worker_type], unique: true, name: 'index_comp_workers'
    add_index :comp_workers, [:competition_id, :user_id]
  end
end
