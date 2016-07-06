class CourseScoreAttribute < ApplicationRecord
  belongs_to :course
  has_many :course_user_scores, foreign_key: :course_sa_id
  validates :name, presence: true, length: {in: 2..15}, uniqueness: {scope: :course_id, message: '同一课程的评分属性名称不同重复'}
  validates :score_per, presence: true, format: {with: /\A[1-9]?[0-9]{1}$|^100+\Z/i, message: '只能为1-100之间的正整数'}
  validates :course_id, presence: true
end
