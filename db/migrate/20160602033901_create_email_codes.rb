class CreateEmailCodes < ActiveRecord::Migration[5.0]
  def change
    create_table :email_codes do |t|
      t.string :email
      t.string :code, limit: 20
      t.string :message_type, limit: 30
      t.integer :failed_attempts
      t.string :ip, limit: 50

      t.timestamps
    end
    add_index :email_codes, :email
    add_index :email_codes, :message_type
    add_index :email_codes, :ip
  end
end
