class TeamUserShip < ApplicationRecord
  belongs_to :user
  belongs_to :team
  belongs_to :event
  belongs_to :school
end
