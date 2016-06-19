class CourseUserShip < ApplicationRecord
  belongs_to :course, counter_cache: :apply_count
  belongs_to :user
  belongs_to :school
  validates :user_id, presence: true, uniqueness: {scope: :course_id, message: '同一用户不能报名一个课程两次'}
  validates :course_id, presence: true
  validates :school_id, presence: true
  validates :grade, presence: true
end
