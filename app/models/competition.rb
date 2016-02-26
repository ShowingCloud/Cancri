class Competition < ApplicationRecord
  has_many :events


  validates :name, presence: true, length: {maximum: 50}, uniqueness: true

  validates :status, presence: true
  STATUS = {
      接受报名: 0,
      报名截止: 1,
      比赛结束: 2,
  }

end
