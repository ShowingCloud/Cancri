class Course < ApplicationRecord
  belongs_to :district
  has_many :course_user_ships
  has_many :users, through: :course_user_ships
  validates :name, presence: true
  validates :target, presence: true, format: {with: /\A[\u4e00-\u9fa5]+\Z/i, message: '请用汉字描述'}
  validates :num, presence: true, format: {with: /\A[1-9]\d+\Z/i, message: '只能为整数'}
  validates :run_time, presence: true
  validates :status, presence: true
  validates :district_id, presence: true
  after_validation :validate_datetime
  STATUS = {
      待审核: 0,
      通过: 1,
      不通过: 2,
  }

  def validate_datetime
    if apply_start_time.present? and apply_end_time.present? and start_time.present? and end_time.present?
      if apply_end_time < apply_start_time
        errors[:apply_start_time] << '报名结束时间不能早于报名开始时间'
      end
      if start_time < apply_end_time
        errors[:start_time] << '比赛开始时间不能早于报名结束时间'
      end
      if start_time > end_time
        errors[:start_time] << '课程结束时间不能早于课程开始时间'
      end
    else
      errors[:start_time] << '课程报名起始时间和课程起始时间为必填项'
    end
  end
end
