class CourseUserScore < ApplicationRecord
  belongs_to :course
  belongs_to :user
  belongs_to :course_score_attribute, foreign_key: :course_sa_id
  belongs_to :course_user_ship
  validates :score, presence: true
  validates :course_user_ship_id, presence: true, uniqueness: {scope: :course_sa_id, message: '该成绩重复了'}
end
