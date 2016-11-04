class Score < ApplicationRecord
  validates :event_id, :schedule_id, :kind, :th, :team1_id, presence: true
  # validates :score1, presence: true
  mount_uploader :confirm_sign, OriginUploader
end
