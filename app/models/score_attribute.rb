class ScoreAttribute < ApplicationRecord
  has_many :event_sa_ships, foreign_key: :score_attribute_id
  has_many :events, through: :event_sa_ships
  WRITE_TYPE = {sd: 1, miaobiao: 2, admin: 3, saidao1: 4, saidao2: 5} # 1 手动
  VALUE_TYPE = {integer: 1, float: 2, boolean: 3}

  validates :name, presence: true
  validates :write_type, presence: true, uniqueness: {scope: :name, message: '同一属性计分方式不能重复'}
  validates :desc, presence: true, :inclusion => {in: ['1', '2', '3']}
end
