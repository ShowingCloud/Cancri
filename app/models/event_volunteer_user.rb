class EventVolunteerUser < ApplicationRecord
  belongs_to :event_volunteer
  belongs_to :event_vol_position, foreign_key: :position
  belongs_to :event
  belongs_to :user
  belongs_to :user_profile, foreign_key: :user_id, primary_key: :user_id
  scope :lj_u_p_u_r, -> { joins('left join user_profiles u_p on u_p.user_id = event_volunteer_users.user_id').joins('left join user_roles u_r on u_r.role_id=3 and u_r.user_id = event_volunteer_users.user_id') }
  validates :status, :user_id, presence: true
  validates :event_volunteer_id, presence: true, uniqueness: {scope: :user_id, message: '同一招募活动不能报名两次'}
  validates :status, inclusion: [0, 1, 2]
  validates :point, allow_blank: true, numericality: {greater_than_or_equal_to: 0}
  after_update :update_points_and_times

  protected

  def update_points_and_times
    if point_changed?
      user_volunteer_role = UserRole.where(user_id: user_id, role_id: 3).take
      user_volunteer_role.update_attributes(points: user_volunteer_role.points+point_change[1].to_i-point_change[0].to_i)
    end

    if status_changed?
      user_volunteer_role = UserRole.where(user_id: user_id, role_id: 3).take
      if status_change == [0, 1]
        user_volunteer_role.update_attributes(times: user_volunteer_role.times+1)
      elsif status_change == [1, 0]
        user_volunteer_role.update_attributes(times: user_volunteer_role.times-1)
      end
    end
  end

end
