class UserFamily < ApplicationRecord
  belongs_to :user
  belongs_to :user_role
  before_validation :check_email_wx_qq
  validates :email, allow_blank: true, format: {with: /\A[^@\s]+@[^@\s]+\z/, message: '格式不正确'}
  validates :qq, allow_blank: true, numericality: true

  protected


  def check_email_wx_qq
    if email.blank? && wx.blank? && qq.blank?
      errors[:email] << '、微信、qq至少填写一个' # 字段名代替邮箱信息
    end
  end
end
