class School < ApplicationRecord
  validates :name, presence: true, uniqueness: {scope: :school_type, message: '一个学校的同一类型不同重复'}
  validates :name, presence: true
  validates :district, presence: true
  validates :school_type, presence: true
  validates :school_city, presence: true
end