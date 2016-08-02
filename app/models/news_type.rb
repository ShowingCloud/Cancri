class NewsType < ApplicationRecord
  validates :name, presence: true, uniqueness: true, length: 1..20
end
