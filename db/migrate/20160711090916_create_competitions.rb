class CreateCompetitions < ActiveRecord::Migration[5.0]
  def change
    create_table :competitions do |t|
      t.string :name, null: false, limit: 50
      t.string :host_year, null: false
      t.text :description
      t.text :emc_contact
      t.string :cover
      t.text :body_html
      t.string :guide_units # 指导单位
      t.string :organizer_units # 主办单位
      t.string :help_units # 协办单位
      t.string :support_units # 赞助商
      t.string :undertake_units # 承办单位
      t.text :video
      t.text :file
      t.integer :status, null: false
      t.datetime :apply_start_time
      t.datetime :apply_end_time
      t.datetime :start_time
      t.datetime :end_time
      t.string :keyword

      t.timestamps
    end
    add_index :competitions, :name, unique: true
    add_index :competitions, :host_year
    add_index :competitions, :status
    add_index :competitions, :start_time
    add_index :competitions, :end_time
  end
end
