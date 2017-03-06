class EventVolPosition < ApplicationRecord
  belongs_to :event_volunteer
  validates :event_volunteer_id, presence: true
  validates :name, presence: true, uniqueness: {scope: :event_volunteer_id, message: '重复'}
end
