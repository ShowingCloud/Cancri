class Team < ApplicationRecord
  belongs_to :user
  belongs_to :event
  belongs_to :district
  has_many :team_user_ships, :dependent => :destroy
  has_many :users, through: :team_user_ship
  mount_uploader :cover, CoverUploader

  GROUP = {primary: 1, middle: 2, junior: 3, high: 4}
  validates :name, presence: true, length: {in: 2..5}, format: {with: /\A[\u4e00-\u9fa5]+\Z/i, message: '队伍名称只能包含中文'}
  validates :user_id, presence: true
  validates :identifier, presence: true
  validates :event_id, presence: true
  validates :teacher, presence: true, format: {with: /\A[\u4e00-\u9fa5]+\Z/i, message: '教师名称只能包含中文'}
  validates :team_code, length: {in: 4..6}, allow_blank: true
  validates_uniqueness_of :event_id, :scope => :user_id
  # validates_uniqueness_of :event_id, :scope => :name
  before_validation :create_identifier, on: :create

  protected
  def create_identifier
    self.identifier = rand(1...9999)
  end
end
