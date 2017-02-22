class EventVolunteerUser < ApplicationRecord
  belongs_to :event_volunteer
  belongs_to :user

  validates :status, :user_id, presence: true
  validates :event_volunteer_id, presence: true, uniqueness: {scope: :user_id, message: '同一招募活动不能报名两次'}
  validates :status, inclusion: [0, 1, 2]
end
