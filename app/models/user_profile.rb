class UserProfile < ApplicationRecord
  belongs_to :user, :dependent => :destroy
  has_many :invites, through: :user
  has_many :comp_workers, through: :user
  has_many :user_roles, through: :user
  has_many :competitions, through: :comp_workers
  belongs_to :schools, class_name: School, foreign_key: :school
  mount_uploader :certificate, CertificateUploader
  GENDER = {male: 1, female: 2}
  after_commit :user_info_validate


  def user_info_validate
    user = self.user
    if self.school.present? & self.grade.present? & self.gender.present? & self.username.present?
      user.update_attributes(validate: 1)
    else
      user.update_attributes(validate: 0)
    end
  end
end
