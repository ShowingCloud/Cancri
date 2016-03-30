class UserProfile < ApplicationRecord
  belongs_to :user, :dependent => :destroy
  has_many :invites, through: :user
  has_many :comp_workers, through: :user
  mount_uploader :certificate, CertificateUploader
  GENDER = {male: 1, female: 2}
end
