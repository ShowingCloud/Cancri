class TeamUserShip < ActiveRecord::Base
  belongs_to :user, foreign_key: :user_id
  belongs_to :team, foreign_key: :team_id
  belongs_to :event, foreign_key: :event_id
  # validates_uniqueness_of :team_id, :scope => [:user_id, :event_id]
  validates_uniqueness_of :user_id, :scope => :team_id
  validates_uniqueness_of :user_id, :scope => :event_id


  validates :user_id, presence: true
  validates :team_id, presence: true
  validates :event_id, presence: true, on: :save

  after_create :create_event

  def create_event
    self.event_id = self.team.event_id
    self.save
  end

  def self.is_join(user_id, event_id)
    player = TeamUserShip.where(user_id: user_id, event_id: event_id).take
    if player.present?
      TRUE
    else
      FALSE
    end
  end
end
