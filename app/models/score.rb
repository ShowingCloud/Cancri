class Score < ApplicationRecord
  validates :event_id, presence: true
  validates :schedule_name, presence: true
  validates :kind, presence: true
  validates :th, presence: true
  validates :team1_id, presence: true
  validates :score1, presence: true
  mount_uploader :confirm_sign, NoteImgUploader
end