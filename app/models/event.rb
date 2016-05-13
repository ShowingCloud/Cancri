class Event < ApplicationRecord
  belongs_to :competition
  has_many :teams
  has_many :team_user_ships #, through: :team
  has_many :event_sa_ships
  has_many :score_attributes, through: :event_sa_ships
  has_many :event_workers
  has_many :child_events, class_name: Event, foreign_key: :parent_id
  belongs_to :parent_event, class_name: Event, foreign_key: :parent_id
  has_many :event_schedules
  TIMER = {wu: 0, app: 1, saidao: 2, has_limit: 3} # 3 有时限但不记录时间
  GROUP = {primary: 1, middle: 2, junior: 3, high: 4}
  mount_uploader :cover, EventUploader

  validates :name, presence: true
  validates :competition_id, presence: true
  validates :status, presence: true
  validates :group, presence: true
  validates :team_min_num, presence: true
  validates :team_max_num, presence: true
  validates :name, presence: true, uniqueness: {scope: :competition_id, message: '同一大赛下一个项目不能出现两次'}
  # validates :apply_start_time, presence: true
  # validates :apply_end_time, presence: true
  # validates :start_time, presence: true
  # validates :end_time, presence: true
  # validate :validate_datetime_parent
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
