class Schedule < ApplicationRecord
  has_many :event_schedules
  validates :name, presence: true, uniqueness: true
end
