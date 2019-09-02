class EventSaShip < ApplicationRecord
  belongs_to :event
  belongs_to :score_attribute, foreign_key: :score_attribute_id, class_name: 'ScoreAttribute'
  belongs_to :score_attribute_parent, foreign_key: :parent_id, class_name: 'ScoreAttribute'
  validates :event_id, :score_attribute_id, presence: true
end
