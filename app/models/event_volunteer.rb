class EventVolunteer < ApplicationRecord
  belongs_to :competition, foreign_key: :type_id
  belongs_to :activity, foreign_key: :type_id
  has_many :event_volunteer_users, :dependent => :destroy
  has_many :event_vol_positions, dependent: :destroy
  scope :lj_e_v_u_u_p_u_r, -> { joins('left join event_volunteer_users e_v_u on e_v_u.event_volunteer_id = event_volunteers.id')
                                    .joins('left join user_roles u_r on u_r.user_id = e_v_u.user_id and u_r.role_id = 3')
                                    .joins('left join user_profiles u_p on u_p.user_id = e_v_u.user_id') }
  validates :name, :event_type, :type_id, :content, presence: true
  after_validation :check_apply_time
  after_validation :check_start_time, on: :create

  protected

  def check_apply_time

    if positions.present?
      self.positions = positions.split('_')
    end

    if apply_start_time.present? && apply_end_time.present?
      if apply_start_time > apply_end_time
        errors[:apply_start_time] << '起始时间不能晚于结束时间!'
      end
    else
      errors[:apply_start_time] << '报名起始时间必填!'
    end
  end

  def check_start_time
    if apply_start_time.present? && apply_start_time < Time.zone.now
      errors[:apply_start_time] << '不能早于现在'
    end
  end
end
