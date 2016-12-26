class District < ApplicationRecord
  has_many :user_profiles
  has_many :courses
  has_many :team_user_ships
  has_many :user_roles
  has_many :competitions
  has_many :activities
  has_many :news
  belongs_to :city
  validates :name, presence: true, uniqueness: {scope: :city_id, message: '同一城市的区县不能重复'}
  validates :city_name, :province_name, presence: true
  scope :sh_districts, -> { where(city_id: 1).select(:id, :name) }
end
