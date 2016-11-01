class Schedule < ApplicationRecord
  has_many :event_schedules
  has_many :events, through: :event_schedules
  validates :name, presence: true, uniqueness: true
end
