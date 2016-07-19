class Event < ApplicationRecord
  belongs_to :competition
  has_many :teams
  has_many :child_events, class_name: Event, foreign_key: :parent_id
  belongs_to :parent_event, class_name: Event, foreign_key: :parent_id
  has_many :team_user_ships
  TIMER = {wu: 0, app: 1, saidao: 2, has_limit: 3} # 3 有时限但不记录时间
  GROUP = {primary: 1, middle: 2, junior: 3, high: 4}
  mount_uploader :cover, CoverUploader

  validates :name, presence: true
  validates :competition_id, presence: true
  validates :status, presence: true
  validates :group, presence: true
  validates :team_min_num, presence: true
  validates :team_max_num, presence: true
  validates :name, presence: true, uniqueness: {scope: :competition_id, message: '同一大赛下一个项目不能出现两次'}
  before_validation :check_include_self
  before_save :update_level

  def update_level
    unless self.level == 2
      if self.parent_id.present? && self.parent_id != self.id
        self.level = 2
      end
    end
  end

  def check_include_self
    if parent_id.present? && parent_id == id
      errors[:parent_id] << '所属项目不能是自己'
    end
  end
end
