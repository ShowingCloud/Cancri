class CourseOpu < ApplicationRecord
  belongs_to :course_user_ship
  belongs_to :course
  validates :cover, :course_user_ship_id, :status, presence: true
  mount_uploader :cover, CoverUploader
end
