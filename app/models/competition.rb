class Competition < ApplicationRecord
  has_many :events, :dependent => :destroy
  belongs_to :district
  has_many :photos, :dependent => :destroy
  has_many :videos, :dependent => :destroy
  has_many :competition_schedules, :dependent => :destroy

  before_validation :validate_datetime
  before_validation :validate_time_now, on: :create
  before_validation :set_district
  validates :name, presence: true, length: {maximum: 60}, uniqueness: true
  validates :host_year, presence: true, inclusion: {in: ['2016', '2017']}
  validates :cover, presence: true, file_size: {less_than: 1.megabyte, message: '大小不能超过1M'}
  validates :aim, :organizing_committee, :date_schedule, presence: true, length: {minimum: 5}
  validates :status, presence: true
  validates :time_schedule, :detail_rule, file_size: {less_than: 10.megabytes, message: '大小不能超过10M'}
  mount_uploader :time_schedule, CompPdfUploader
  mount_uploader :detail_rule, CompPdfUploader
  mount_uploader :cover, CoverUploader
  STATUS = {
      待显示: 0,
      显示: 1,
      结束: 2,
  }

  def set_district
    if district_id == nil
      self.district_id = 0
    end
  end

  def validate_datetime
    if apply_start_time.present? && apply_end_time.present? && start_time.present? && end_time.present? && school_audit_time.present? && district_audit_time.present?
      if apply_end_time < apply_start_time
        errors[:apply_end_time] << '报名结束时间 要晚于 报名开始时间'
      end


      if school_audit_time <= apply_end_time
        errors[:apply_end_time] << '学校审核截止时间 要晚于 报名结束时间'
      end

      if district_audit_time <= school_audit_time
        errors[:apply_end_time] << '区县审核截止时间 要晚于 学校审核截止时间'
      end

      if start_time <= district_audit_time
        errors[:start_time] << '比赛开始时间 要晚于 区县审核截止时间'
      end
      if start_time >= end_time
        errors[:end_time] << '比赛结束时间 要晚于 比赛开始时间'
      end
    else
      errors[:end_time] << '请将比赛6个相关时间填写完整'
    end
  end

  def validate_time_now
    if apply_start_time.present? && apply_start_time < Time.now
      errors[:apply_end_time] << '报名开始时间 不能早于 当前时间'
    end
  end
end
