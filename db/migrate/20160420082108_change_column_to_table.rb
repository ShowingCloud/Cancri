class ChangeColumnToTable < ActiveRecord::Migration[5.0]
  def change
    change_column :email_codes, :email, :string
  end
end
