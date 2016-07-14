class Competition < ApplicationRecord
  has_many :events
  has_many :photos
  has_many :videos

  validates :name, presence: true, length: {maximum: 50}, uniqueness: true
  validates :host_year, presence: true, length: {is: 4}, numericality: true

  validates :status, presence: true
  mount_uploader :time_schedule, CompPdfUploader
  mount_uploader :detail_rule, CompPdfUploader
  STATUS = {
      接受报名: 0,
      报名截止: 1,
      比赛结束: 2,
  }
end
