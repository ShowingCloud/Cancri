class EventSchedule < ApplicationRecord
  belongs_to :event
  belongs_to :schedule
  validates :event_id, presence: true
  validates :schedule_id, presence: true, uniqueness: {scope: :event_id, message: '同一赛程名在一个项目中不能出现两次'}
  validates :kind, presence: true, inclusion: {in: [1, 2]}
end
