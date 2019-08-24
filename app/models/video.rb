class Video < ApplicationRecord
  belongs_to :competition, foreign_key: :type_id
  belongs_to :activity, foreign_key: :type_id
  validates :video_type, presence: true, inclusion: {in: [0, 1]}
  validates :type_id, presence: true
  mount_uploader :video, VideoUploader


end

