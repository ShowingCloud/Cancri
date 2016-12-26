class Province < ApplicationRecord
  has_many :cities
  has_many :districts, through: :cities
end
