class Regulation < ApplicationRecord
  validates :name, :content, presence: true
  validates :regulation_type, inclusion: [1]
  validates :regulation_type, uniqueness: {scope: :name, message: '同一名字的类型不能重复'}
end
