class District < ApplicationRecord
  has_many :teams
  has_many :user_profiles
  validates :name, presence: true, uniqueness: true
end
