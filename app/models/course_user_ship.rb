class CourseUserShip < ApplicationRecord
  belongs_to :course, counter_cache: :apply_count
  belongs_to :user
  belongs_to :school
  has_many :course_user_scores
  has_many :course_score_attributes, foreign_key: :course_id
  validates :user_id, presence: true, uniqueness: {scope: :course_id, message: '同一用户不能报名一个课程两次'}
  validates :course_id, presence: true
  validates :school_id, presence: true
  validates :grade, presence: true
end
