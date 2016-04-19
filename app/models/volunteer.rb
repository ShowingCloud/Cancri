class Volunteer < ApplicationRecord
  belongs_to :competition
  belongs_to :news_type
  validates :competition_id, presence: true
  validates :news_type_id, presence: true, uniqueness: {scope: :competition_id, message: '一个比赛对应的同一类型不能超过两个'}
  validate :validate_datetime_parent

  def validate_datetime_parent

    if apply_start_time.present? and apply_end_time.present?
      if apply_end_time < apply_start_time
        errors[:apply_start_time] << '报名结束时间 不能早于 报名开始时间'
      end
    else
      errors[:apply_end_time] << '报名起始时间为必填项'
    end
  end
end
