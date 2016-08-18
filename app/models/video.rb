class Video < ApplicationRecord
  validates :video_type, presence: true, inclusion: {in: [0, 1]}
  validates :type_id, presence: true
  mount_uploader :video, VideoUploader


end

