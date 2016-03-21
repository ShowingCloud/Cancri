class Event < ApplicationRecord
  belongs_to :competition
  has_many :teams
  has_many :team_user_ships #, through: :team
  has_many :event_schedules

  mount_uploader :cover, EventUploader

  validates :name, presence: true
  validates :competition_id, presence: true
  validates :status, presence: true
  validates :team_min_num, presence: true
  validates :team_max_num, presence: true
  # validates :apply_start_time, presence: true
  # validates :apply_end_time, presence: true
  # validates :start_time, presence: true
  # validates :end_time, presence: true
  validate :validate_datetime_parent
  before_save :update_level

  def update_level
    if self.parent_id.present? && self.parent_id != self.id
      self.level = 2
    end
  end

  def validate_datetime_parent

    if apply_start_time.present? and apply_end_time.present? and start_time.present? and end_time.present?
      if apply_end_time < apply_start_time
        errors[:apply_start_time] << '报名结束时间不能早于报名开始时间'
      end
      if start_time < apply_end_time
        errors[:start_time] << '比赛开始时间不能早于报名结束时间'
      end
      if start_time > end_time
        errors[:end_time] << '比赛结束时间不能早于比赛开始时间'
      end
    else
      errors[:end_time] << '比赛报名起始时间和比赛起始时间为必填项'
    end
    if parent_id.present? && parent_id == id
      errors[:parent_id] << '所属项目不能是自己'
    end
  end
end
