class Course < ApplicationRecord
  belongs_to :district
  has_many :course_user_ships
  belongs_to :user
  has_many :users, through: :course_user_ships
  has_many :course_files, :dependent => :destroy, foreign_key: :course_id
  has_many :course_score_attributes, :dependent => :destroy, foreign_key: :course_id
  validates :name, presence: true, uniqueness: true
  validates :target, presence: true, format: {with: /\A[\u4e00-\u9fa5]+\Z/i, message: '请用汉字描述'}
  validates :num, presence: true, format: {with: /\A[1-9]\d+\Z/i, message: '只能为整数'}
  validates :run_time, presence: true
  validates :run_address, presence: true
  validates :status, presence: true
  validates :district_id, presence: true
  validates :user_id, presence: true
  after_validation :validate_datetime

  attr_accessor :course_wave
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
        errors[:start_time] << '课程开始时间不能早于报名结束时间'
      end
      if start_time > end_time
        errors[:start_time] << '课程结束时间不能早于课程开始时间'
      end
      if apply_end_time < Time.now
        errors[:start_time] << '课程报名结束时间不能早于现在'
      end
    else
      errors[:start_time] << '课程报名起始时间和课程开课起始时间为必填项'
    end
  end
end
