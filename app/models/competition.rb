class Competition < ApplicationRecord
  has_many :events
  has_many :competition_schedules
  has_many :comp_workers
  has_many :volunteers
  has_many :photos
  has_many :videos
  accepts_nested_attributes_for :photos
  accepts_nested_attributes_for :videos
  mount_uploader :time_schedule, CompPdfUploader
  mount_uploader :detail_rule, CompPdfUploader

  validates :name, presence: true, length: {maximum: 50}, uniqueness: true
  validates :host_year, presence: true, length: {is: 4}, numericality: true

  validates :status, presence: true
  STATUS = {
      接受报名: 0,
      报名截止: 1,
      比赛结束: 2,
  }

end
