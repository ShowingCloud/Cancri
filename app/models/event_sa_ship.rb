class EventSaShip < ApplicationRecord
  belongs_to :event
  belongs_to :score_attribute
end
