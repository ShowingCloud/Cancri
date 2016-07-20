class AddColumnToCompetitions < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :aim, :text
    add_column :competitions, :organizing_committee, :text
    add_column :competitions, :date_schedule, :text
    add_column :competitions, :apply_require, :text
    add_column :competitions, :reward_method, :text
    add_column :competitions, :apply_method, :text
    add_column :competitions, :school_audit_time, :datetime, null: false
    add_column :competitions, :district_audit_time, :datetime, null: false
    add_index :competitions, :school_audit_time
    add_index :competitions, :district_audit_time
  end
end
