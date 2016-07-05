class CourseFile < ApplicationRecord
  belongs_to :course
  validates :course_id, presence: true
  validates :course_ware, presence: true

  mount_uploader :course_ware, FileUploader
end