class District < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
