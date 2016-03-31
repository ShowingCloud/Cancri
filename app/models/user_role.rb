class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role
  belongs_to :user_profile
  validates_uniqueness_of :user_id, :scope => :role_id
  validates :user_id, presence: true
  validates :role_id, presence: true
end
