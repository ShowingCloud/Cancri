class UserProfile < ApplicationRecord
  belongs_to :user, :dependent => :destroy
  has_many :invites, through: :user
  has_many :comp_workers, through: :user
  has_many :user_roles, through: :user
  has_many :competitions, through: :comp_workers
  belongs_to :schools, class_name: School, foreign_key: :school
  belongs_to :district, foreign_key: :district
  mount_uploader :certificate, CertificateUploader
  GENDER = {male: 1, female: 2}
end
