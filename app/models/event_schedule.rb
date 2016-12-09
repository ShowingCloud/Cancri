class EventSchedule < ApplicationRecord
  belongs_to :event
  belongs_to :schedule
  scope :event_group_schedules, ->(group, event_id) { left_joins(:schedule).where(group: group, event_id: event_id).select(:schedule_id, 'schedules.name') }
  validates :event_id, presence: true
  validates :schedule_id, presence: true, uniqueness: {scope: [:event_id, :group], message: '同一赛程名在一个项目的同一个组别中不能出现两次'}
  validates :kind, presence: true, inclusion: {in: [1, 2]}
  validates :group, presence: true, inclusion: {in: [1, 2, 3, 4]}
end
