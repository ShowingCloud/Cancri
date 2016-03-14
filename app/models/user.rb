class User < ApplicationRecord
  has_one :user_profile, :dependent => :destroy
  has_many :user_roles
  has_many :roles, through: :user_roles
  has_many :team_user_ships, foreign_key: :user_id
  has_and_belongs_to_many :teams
  has_many :invites
  has_many :access_grants, dependent: :delete_all
  has_many :notifications
  mount_uploader :avatar, AvatarUploader

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :timeoutable, :omniauthable, :authentication_keys => [:login]
  # :confirmable

  validates :nickname, presence: true, uniqueness: true, length: {in: 2..10}, format: {with: /\A[\u4e00-\u9fa5_a-zA-Z0-9]+\Z/i, message: '昵称只能包含中文、数字、字母、下划线'}
  validates :password, length: {in: 6..30}, format: {with: /\A[\x21-\x7e]+\Z/i, message: '密码只能包含数字、字母、特殊字符'}, allow_nil: true
  validates :password, presence: true, on: :create
  after_create :create_soulmate

  def to_hash
    user_json = {
        id: self.id,
        term: self.email,
        score: self.sign_in_count
    }
    JSON.parse(user_json.to_json)
  end

  def email_changed?
    false
  end

  def email_required?
    false
  end

  attr_accessor :login
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

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end

  private

  def create_soulmate
    Soulmate::Loader.new("user").add self.to_hash
  end
end
