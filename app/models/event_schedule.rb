class EventSchedule < ApplicationRecord
  belongs_to :event
  belongs_to :schedule
  validates :event_id, presence: true
  validates :schedule_id, presence: true
  validates :kind, inclusion: {in: %w(1 2)}
end
