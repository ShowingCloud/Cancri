class Video < ApplicationRecord
  belongs_to :competition
  validates :competition_id, presence: true
  mount_uploader :video, VideoUploader


end

