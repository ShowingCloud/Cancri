class CreateDoorkeeperTables < ActiveRecord::Migration
  def change
    create_table :oauth_applications do |t|
      t.string :name, null: false
      t.string :uid, null: false
      t.string :secret, null: false
      t.text :redirect_uri, null: false
      t.string :scopes, null: false, default: ''
      t.timestamps
      t.integer :owner_id # add
      t.string :owner_type # add
    end

    add_index :oauth_applications, :uid, unique: true
    add_index :oauth_applications, [:owner_id, :owner_type]

    create_table :oauth_access_grants do |t|
      t.integer :resource_owner_id, null: false
      t.integer :application_id, null: false
      t.string :token, null: false
      # t.integer :expires_in, null: false # jason update
      t.integer :expires_in, limit: 8, null: true
      t.text :redirect_uri, null: false
      t.datetime :created_at, null: false
      t.datetime :revoked_at
      t.string :scopes
    end

    add_index :oauth_access_grants, :token, unique: true

    create_table :oauth_access_tokens do |t|
      t.integer :resource_owner_id
      t.integer :application_id

      # If you use a custom token generator you may need to change this column
      # from string to text, so that it accepts tokens larger than 255
      # characters. More info on custom token generators in:
      # https://github.com/doorkeeper-gem/doorkeeper/tree/v3.0.0.rc1#custom-access-token-generator
      #
      # t.text     :token,             null: false
      t.string :token, null: false

      t.string :refresh_token
      # t.integer :expires_in  # jason update
      t.integer :expires_in, limit: 8, null: true
      t.datetime :revoked_at
      t.datetime :created_at, null: false
      t.string :scopes
    end

    add_index :oauth_access_tokens, :token, unique: true
    add_index :oauth_access_tokens, :resource_owner_id
    add_index :oauth_access_tokens, :refresh_token, unique: true
  end
end