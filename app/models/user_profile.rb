class UserProfile < ApplicationRecord
  belongs_to :user, :dependent => :destroy
  has_many :invites, through: :user
  has_many :comp_workers, through: :user
  has_many :user_roles, through: :user
  has_many :competitions, through: :comp_workers
  belongs_to :schools, class_name: School, foreign_key: :school
  belongs_to :user_district, class_name: District, foreign_key: :district
  mount_uploader :certificate, CertificateUploader
  GENDER = {male: 1, female: 2}
  after_commit :user_info_validate

  def user_info_validate
    if self.school.present? & self.grade.present? & self.bj.present? & self.gender.present? & self.username.present?
      self.user.update_attributes(validate_status: 1)
    else
      self.user.update_attributes(validate_status: 0)
    end
  end
end
