class Consult < ApplicationRecord
  belongs_to :user
  belongs_to :admin, optional: true
  validates :user_id, presence: true
  validates :content, presence: true, length: {in: 6..255}
  attr_accessor :reply_content
end
