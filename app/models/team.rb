class Team < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  has_many :team_user_ships, foreign_key: :team_id
  has_many :users, through: :team_user_ships
  has_many :scores

  validates :name, presence: true, length: {in: 2..6}
  validates :user_id, presence: true
  validates :event_id, presence: true
  validates :teacher, presence: true
  validates :team_code, length: {in: 4..6}
  validates_uniqueness_of :event_id, :scope => :user_id
  validates_uniqueness_of :event_id, :scope => :name

  mount_uploader :cover, CoverUploader
end