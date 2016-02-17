class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :timeoutable, :authentication_keys => [:login]
  # :confirmable

  validates :nickname, presence: true, uniqueness: true, length: {in: 2..10} #, format: {with: /\A1[34578][0-9]{9}\Z/i, message: '格式不正确'}


  def email_changed?
    false
  end

  def email_required?
    false
  end

  attr_accessor :login

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(['nickname = :value OR email = :value OR mobile = :value', {:value => login}]).first
    else
      where(conditions).first
    end
  end
end
