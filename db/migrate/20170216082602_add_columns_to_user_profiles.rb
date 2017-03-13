class AddColumnsToUserProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :user_profiles, :school_name, :string
    add_column :user_profiles, :alipay_account, :string
  end
end
