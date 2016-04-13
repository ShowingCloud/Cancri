class AddColumnsToUserProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :user_profiles, :roles, :string
    add_column :user_profiles, :sk_station, :integer
    add_column :user_profiles, :standby_school, :integer
    add_index :user_profiles, :roles
    add_index :user_profiles, :sk_station
  end
end
