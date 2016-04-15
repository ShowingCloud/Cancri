class CompetitionSchedule < ApplicationRecord
  belongs_to :competition

  validates :name, presence: true
  validates :start_time, presence: true
  validates :competition_id, presence: true
end