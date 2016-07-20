class UserProfile < ApplicationRecord
  belongs_to :user
  belongs_to :school, optional: true
  belongs_to :district, optional: true
  has_many :user_roles, through: :user
  validates :gender, inclusion: [1, 2], allow_blank: true
  validates :school_id, numericality: {only_integer: true}, allow_blank: true
  validates :district_id, numericality: {only_integer: true}, allow_blank: true
  GENDER = {male: 1, female: 2}
  mount_uploader :certificate, CoverUploader

  attr_accessor :desc
  attr_accessor :cover
end
