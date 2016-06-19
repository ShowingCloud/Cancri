class School < ApplicationRecord
  has_many :user_profiles
  has_many :course_user_ships
  validates :name, presence: true
  validates :district_id, presence: true
  validates :school_type, presence: true
end
