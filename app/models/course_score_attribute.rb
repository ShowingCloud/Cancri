class CourseScoreAttribute < ApplicationRecord
  belongs_to :course
  validates :name, presence: true, length: {in: 2..15}, uniqueness: {scope: :name, message: '同一课程的评分属性名称不同重复'}
  validates :score_per, presence: true
  validates :course_id, presence: true
end
