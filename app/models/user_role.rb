class UserRole < ApplicationRecord
  belongs_to :role
  belongs_to :user
  belongs_to :user_profile
  validates :user_id, presence: true, uniqueness: {scope: :role_id, message: '一个用户的同一角色不同重复'}
  validates :role_id, presence: true
  mount_uploader :cover, CoverUploader
end
