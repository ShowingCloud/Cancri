class EventVolunteerUser < ApplicationRecord
  belongs_to :event_volunteer
  belongs_to :user

  validates :status, :user_id, presence: true
  validates :event_volunteer_id, presence: true, uniqueness: {scope: :user_id, message: '同一招募活动不能报名两次'}
  validates :status, inclusion: [0, 1, 2]
  after_update :update_points_and_times

  protected

  def update_points_and_times
    if point_changed?
      user_volunteer_role = UserRole.where(user_id: user_id, role_id: 3).take
      user_volunteer_role.update_attributes(points: user_volunteer_role.points+point_change[1]-point_change[0])
    end

    if status_changed?
      user_volunteer_role = UserRole.where(user_id: 1, role_id: 3).take
      if status_change == [0, 1]
        user_volunteer_role.update_attributes(times: user_volunteer_role.times+1)
      elsif status_change == [1, 0]
        user_volunteer_role.update_attributes(times: user_volunteer_role.times-1)
      end
    end
  end

end
