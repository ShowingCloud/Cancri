class EventVolunteer < ApplicationRecord
  validates :name, :event_type, :type_id, :content, presence: true
  after_validation :check_apply_time
  after_validation :check_start_time, on: :create

  protected

  def check_apply_time
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
      errors[:apply_start_time] << '报名开始时间不能早于现在'
    end
  end
end
