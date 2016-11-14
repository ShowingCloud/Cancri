class UserProfile < ApplicationRecord
  belongs_to :user
  belongs_to :school, optional: true
  belongs_to :district, optional: true
  has_many :user_roles, through: :user
  before_validation :validate_data
  validates :gender, inclusion: [1, 2], allow_blank: true
  validates :school_id, numericality: {only_integer: true}, allow_blank: true
  validates :grade, numericality: {only_integer: true}, allow_blank: true
  validates :district_id, numericality: {only_integer: true}, allow_blank: true

  GENDER = {male: 1, female: 2}
  mount_uploader :certificate, CoverUploader

  attr_accessor :desc
  attr_accessor :cover

  protected

  def validate_data
    if username.present? && /\A[a-zA-Z\u4e00-\u9fa5]{2,10}\Z/.match(username)== nil
      errors[:username] << '只能包含2-10位中文或英文'
    end

    if (grade.present? && ([grade.to_i] & [10, 11, 12]).present?) && (/^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$/.match(identity_card) == nil)
      errors[:grade] << '高中生请正确填写18位身份证号'
    end
  end
end
