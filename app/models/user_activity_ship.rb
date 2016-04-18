class UserActivityShip < ApplicationRecord
  belongs_to :activity
  belongs_to :user

  validates :user_id, presence: true
  validates :activity_id, presence: true, uniqueness: {scope: :user_id, message: '一个用户不能报名一个活动两次'}

end
