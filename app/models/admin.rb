class Admin < ApplicationRecord
  has_many :news
  has_many :consults
  has_secure_password
  include AccountConcern

  validates :job_number, presence: true, length: {minimum: 3, maximum: 10}, uniqueness: true
  validates :password, length: {minimum: 6, maximum: 20}, allow_blank: true
  validates :password, presence: true, on: :create
  validates :name, presence: true
  validates :permissions, presence: true

  PERMISSIONS = {
      super_admin: '超级管理员',
      admin: '管理员',
      super_editor: '总编',
      editor: '编辑',
      score: '成绩录入员',
      audit: '审核员',
      teacher: '教师',
  }

  GENDER = {male: 1, female: 2}

  def auth_permissions(permissions)
    if permissions.is_a?(Array) and self.permissions.present?
      (self.permissions.split(',') & permissions).count > 0
    else
      FALSE
    end
  end
end
