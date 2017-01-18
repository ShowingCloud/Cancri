class CourseOpu < ApplicationRecord
  belongs_to :course_user_ship
  belongs_to :course
end
