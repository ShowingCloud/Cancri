class Activity < ApplicationRecord
  has_many :activity_user_ships
  has_many :users, through: :activity_user_ships
  has_many :child_activities, class_name: Activity, foreign_key: :parent_id
  belongs_to :parent_activity, class_name: Activity, foreign_key: :parent_id
  belongs_to :district

  before_validation :check_include_self
  validates :name, presence: true, length: {maximum: 50}, uniqueness: true
  validates :host_year, presence: true
  validates :host_address, presence: true
  validates :cover, presence: true
  validates :status, presence: true
  validate :validate_datetime_parent
  before_save :set_level
  mount_uploader :cover, CoverUploader

  private

  def check_include_self
    if parent_id.present? && parent_id == id
      errors[:parent_id] << '所属项目不能是自己'
    end
  end

  def set_level
    if parent_id.present?
      unless level==2
        self.level = 2
      end
    end
  end

  def validate_datetime_parent

    if apply_start_time.present? and apply_end_time.present? and start_time.present? and end_time.present?
      if apply_end_time < apply_start_time
        errors[:apply_start_time] << '报名结束时间 不能早于 报名开始时间'
      end
      if start_time < apply_end_time
        errors[:start_time] << '活动开始时间 不能早于 报名结束时间'
      end
      if start_time > end_time
        errors[:end_time] << '活动结束时间 不能早于 活动开始时间'
      end
    else
      errors[:end_time] << '活动报名起始时间和活动举办起始时间为必填项'
    end
  end

end
