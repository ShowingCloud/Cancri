class EventVolPosition < ApplicationRecord
  belongs_to :event_volunteer
  has_many :event_volunteer_users, foreign_key: :position
  validates :event_volunteer_id, presence: true
  validates :name, presence: true, uniqueness: {scope: :event_volunteer_id, message: '已存在'}
end
