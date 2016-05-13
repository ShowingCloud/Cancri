class UserPoint < ApplicationRecord
  belongs_to :user
  belongs_to :prize
  mount_uploader :cover, CoverUploader
end
