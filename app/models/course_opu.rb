class CourseOpu < ApplicationRecord
  belongs_to :course_user_ship, counter_cache: :opus_count
  belongs_to :course
  validates :course_user_ship_id, :status, presence: true
  validates :cover, presence: true, file_size: {less_than: 1.megabyte, message: '大小不能超过1M'}
  mount_uploader :cover, CoverUploader
end
