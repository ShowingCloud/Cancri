class CourseUserShip < ApplicationRecord
  belongs_to :course
  belongs_to :user
  belongs_to :school
  validates :user_id, presence: true, uniqueness: {scope: :course_id, message: '同一用户不能报名一个课程两次'}
  validates :course_id, presence: true
end
