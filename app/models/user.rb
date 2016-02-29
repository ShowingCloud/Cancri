class User < ApplicationRecord
  has_one :user_profile, :dependent => :destroy
  has_many :user_roles
  has_many :roles, through: :user_roles
  has_many :team_user_ships, foreign_key: :user_id
  has_and_belongs_to_many :teams
  mount_uploader :avatar, AvatarUploader

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :timeoutable, :authentication_keys => [:login]
  # :confirmable

  validates :nickname, presence: true, uniqueness: true, length: {in: 2..10}, format: {with: /\A[\u4e00-\u9fa5_a-zA-Z0-9]+\Z/i, message: '昵称只能包含中文、数字、字母、下划线'}
  validates :password, length: {in: 6..30}, format: {with: /\A[\x21-\x7e]+\Z/i, message: '密码只能包含数字、字母、特殊字符'}, allow_nil: true
  validates :password, presence: true, on: :create

  def email_changed?
    false
  end

  def email_required?
    false
  end

  attr_accessor :login
  attr_accessor :email_code
  attr_accessor :mobile_info

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(['nickname = :value OR email = :value OR mobile = :value', {:value => login}]).first
    else
      where(conditions).first
    end
  end
end
