class District < ApplicationRecord
  has_many :user_profiles
  has_many :courses
  has_many :team_user_ships
  has_many :user_roles
  has_many :competitions
  has_many :activities
  has_many :news
  validates :name, presence: true, uniqueness: {scope: :city, message: '同一城市的区县不同重复'}
  validates :city, presence: true
end
