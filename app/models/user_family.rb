class UserFamily < ApplicationRecord
  belongs_to :user
  before_validation :check_email_wx_qq
  validates :email, allow_blank: true, format: {with: /\A[^@\s]+@[^@\s]+\z/, message: '格式不正确'}
  validates :qq, allow_blank: true, numericality: true

  protected


  def check_email_wx_qq
    if email.nil? && wx.nil? && qq.nil?
      errors[:email] << '邮箱、微信、qq至少填写一个'
    end
  end
end
