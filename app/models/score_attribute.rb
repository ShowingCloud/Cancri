class ScoreAttribute < ApplicationRecord
  has_many :event_sa_ships, foreign_key: :score_attribute_id
  has_many :events, through: :event_sa_ships
end
