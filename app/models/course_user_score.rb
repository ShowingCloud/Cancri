class CourseUserScore < ApplicationRecord
  belongs_to :course
  belongs_to :user
  belongs_to :course_score_attribute, foreign_key: :course_sa_id
end
