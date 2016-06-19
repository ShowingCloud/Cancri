class UserProfile < ApplicationRecord
  belongs_to :user
  belongs_to :school, optional: true
  belongs_to :district, optional: true
  has_many :user_roles, through: :user
  GENDER = {male: 1, female: 2}
  mount_uploader :certificate, CoverUploader

  attr_accessor :desc
  attr_accessor :coverqq
end
