class TeamUserShip < ApplicationRecord
  belongs_to :team, counter_cache: :players
  belongs_to :user
  belongs_to :event
  belongs_to :school
  belongs_to :district
  validates :team_id, :event_id, presence: true
  validates :user_id, presence: true, uniqueness: {scope: :team_id, message: '一个用户只能以一个队伍报名'}
  validates :event_id, presence: true
  validates :status, inclusion: [0, 1, 2], presence: true # 0: 队员申请; 1:成功; 2:队长邀请
  # validates :school_id, :grade, :district_id, presence: true, numericality: {only_integer: true}
end
