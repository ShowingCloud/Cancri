class CreateDemeanors < ActiveRecord::Migration[5.0]
  def change
    create_table :demeanors do |t|
      t.integer :competition_id
      t.string :name
      t.integer :file_type
      t.integer :status
      t.integer :sort
      t.string :desc

      t.timestamps
    end

    add_index :demeanors, :competition_id
    add_index :demeanors, :file_type
    add_index :demeanors, [:competition_id, :file_type]
    add_index :demeanors, :status
    add_index :demeanors, :sort
  end
end
