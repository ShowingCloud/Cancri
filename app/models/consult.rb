class Consult < ApplicationRecord
  belongs_to :user
  belongs_to :admin
  validates :user_id, presence: true
  validates :content, presence: true, length: {in: 6..150}
end
