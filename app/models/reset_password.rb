class ResetPassword

  include Virtus::Model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :mobile, String
  attribute :password, String
  attribute :password_confirmation, String
  attribute :mobile_code, String

  validates :mobile, presence: true, length: {is: 11}, numericality: true
  validates :password, presence: true, length: {in: 6..30}, format: {with: /\A[\x21-\x7e]+\Z/i, message: '密码只能包含数字、字母、特殊字符'}
  validates :password_confirmation, presence: true
  validates :mobile_code, presence: true, length: {is: 4}

  validate :mobile_validation
  validate :mobile_code_validation
  validate :password_validation

  def mobile_validation
    unless User.find_by_mobile(self.mobile).present?
      errors[:mobile] << "该手机号码尚未验证"
    end
  end

  def password_validation
    unless password == password_confirmation
      errors[:password_confirmation] << "与新密码不一致"
    end
  end

  def mobile_code_validation
    sms = SMSService.new(self.mobile)
    status, message = sms.validate?(self.mobile_code, SMSService::TYPE_CODE_RESET_PASSWORD)
    unless status
      errors[:mobile_code] << message
    end
  end

  def persisted?
    FALSE
  end

  def save
    if valid?
      reset_password(self.mobile)
    else
      nil
    end
  end

  private

  def reset_password(mobile)
    user = User.find_by_mobile(mobile)
    user.password = self.password
    user.save
  end
end