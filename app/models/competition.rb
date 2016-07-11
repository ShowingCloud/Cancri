class Competition < ApplicationRecord

  validates :name, presence: true, length: {maximum: 50}, uniqueness: true
  validates :host_year, presence: true, length: {is: 4}, numericality: true

  validates :status, presence: true
  STATUS = {
      接受报名: 0,
      报名截止: 1,
      比赛结束: 2,
  }
end
