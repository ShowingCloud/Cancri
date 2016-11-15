class ScoreAttribute < ApplicationRecord
  has_many :event_sa_ships, foreign_key: :score_attribute_id
  has_many :events, through: :event_sa_ships
  WRITE_TYPE = {sd: 1, app: 2, saidao: 3} # 1 手动
  VALUE_TYPE = {integer: 1, float: 2}

  validates :name, presence: true
  validates :write_type, presence: true, uniqueness: {scope: :name, message: '同一属性计分方式不能重复'}
end
