class UserProfile < ApplicationRecord
  belongs_to :user
  belongs_to :school, optional: true
  belongs_to :district, optional: true
  belongs_to :user_role
  before_validation :validate_data
  validates :gender, inclusion: [1, 2], allow_blank: true
  validates :school_id, numericality: {:greater_than => 0}, allow_blank: true
  validates :grade, allow_blank: true, numericality: {:greater_than => 0}
  validates :district_id, numericality: {:greater_than => 0}, allow_blank: true
  validates :student_code, allow_blank: true, uniqueness: true, length: {minimum: 1}, format: {with: /\A[A-Z0-9]+\Z/i, message: '只能包含数字、字母'}
  validates :bj, allow_blank: true, :numericality => {:greater_than => 0}
  validates :identity_card, allow_blank: true, format: {with: /\A[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)+\Z/i, message: '格式不正确'}

  GENDER = {male: 1, female: 2}
  mount_uploader :certificate, CoverUploader

  attr_accessor :desc
  attr_accessor :cover

  protected

  def validate_data
    if username.present? && /\A[a-zA-Z\u4e00-\u9fa5]{2,10}\Z/.match(username)== nil
      errors[:username] << '只能包含2-10位中文或英文'
    end

    if alipay_account.present?
      unless Regular.is_mobile?(alipay_account) || Regular.is_email?(alipay_account)
        errors[:alipay_account] << '格式不正确（只能为手机号或者邮箱）'
      end
    end

    if birthday.present? && identity_card.present?
      if /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$/.match(identity_card) == nil
        errors[:identity_card] << '请正确填写18位身份证号'
      end
      if birthday.to_s.gsub('-', '') != identity_card[6..13]
        errors[:birthday] << '与身份证信息不符'
      end

    end

    # if (grade.present? && ([grade.to_i] & [10, 11, 12]).present?) && (/^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$/.match(identity_card) == nil)
    #   errors[:grade] << '高中生请正确填写18位身份证号'
    # end
  end
end
