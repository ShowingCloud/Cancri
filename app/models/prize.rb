class Prize < ApplicationRecord
  has_many :user_points
  validates :host_year, presence: true
  validates :name, presence: true, uniqueness: {scope: :host_year, message: '同一年份中一个比赛名不能出现两次'}
  validates :point, presence: true
  validates :prize, presence: true
end
