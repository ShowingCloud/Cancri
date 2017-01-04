class User < ApplicationRecord
  has_one :user_profile, :dependent => :destroy
  has_many :user_roles
  has_many :roles, through: :user_roles
  has_many :notifications
  has_many :course_user_ships
  has_many :courses, through: :course_user_ships
  has_many :consults
  has_many :course_user_scores
  has_many :teams, :dependent => :destroy
  has_many :team_user_ships, :dependent => :destroy
  has_one :user_family, :dependent => :destroy
  has_one :user_hacker, :dependent => :destroy
  mount_uploader :avatar, AvatarUploader
  accepts_nested_attributes_for :user_profile, allow_destroy: true
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :timeoutable, :omniauthable, :omniauth_providers => [:cas]

  validates :nickname, presence: true, uniqueness: true, length: {in: 2..20}, format: {with: /\A[\u4e00-\u9fa5_a-zA-Z0-9]+\Z/i, message: '昵称只能包含中文、数字、字母、下划线'}
  validates :email, uniqueness: true, allow_blank: true, format: {with: /\A[^@\s]+@[^@\s]+\z/, message: '格式不正确'}


  def email_changed?
    false
  end

  def email_required?
    false
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  attr_accessor :email_info
  attr_accessor :email_code
  attr_accessor :mobile_info
  attr_accessor :return_url

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(['nickname = :value OR email = :value OR mobile = :value', {:value => login}]).first
    else
      where(conditions).first
    end
  end

  def self.from_sso(auth)
    id = auth.extra.id
    user = find_by(id: id)
    mobile = auth.extra.try(:mobile)
    email = auth.info.try(:email)
    email = email.present? ? email.strip : ''
    mobile = mobile.present? ? mobile.strip : ''
    mobile = '' if mobile == "--- \n..."
    email = '' if email == "--- \n..."
    if user.nil?
      user = create(id: auth.extra.id, nickname: auth.info.nickname, mobile: mobile, email: email)
    else
      user.update_attributes(email: email, mobile: mobile)
    end
    user
  end

  private

end
