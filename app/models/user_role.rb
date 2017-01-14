class UserRole < ApplicationRecord
  belongs_to :role
  belongs_to :user
  belongs_to :user_profile, optional: true
  belongs_to :school
  belongs_to :district
  has_one :user_family, :dependent => :destroy
  has_one :user_hacker, :dependent => :destroy
  scope :left_join_u_p, -> { joins('left join user_profiles u_p on u_p.user_id = user_roles.user_id') }
  scope :left_join_s_d, -> { joins('left join schools s on s.id = user_roles.school_id').joins('left join districts d on d.id = s.district_id') }
  scope :user_role_info, ->(user_ids) { left_join_s_d.where(user_id: user_ids, role_id: 1, status: 1).pluck('d.id as district_id') }
  validates :status, inclusion: [0, 1, 2]
  validates :role_id, inclusion: [1, 2]
  validates :school_id, presence: true, numericality: {:greater_than => 0, message: '参数不规范'}
  validates :user_id, presence: true, uniqueness: {scope: [:role_id, :role_type], message: '一个用户的同一角色不同重复'}
  validates :role_type, presence: true
  validates :role_type, uniqueness: {scope: :school_id, message: '该学校已有该角色老师'}, if: :role_type_3?, on: :update
  validates :role_type, uniqueness: {scope: :district_id, message: '该区县已有该角色老师'}, if: :role_type_2?, on: :update

  after_update_commit :update_school_teacher_role
  mount_uploader :cover, CoverUploader

  private

  def update_school_teacher_role
    if role_type == 3
      status_change = attribute_previous_change(:status)
      if status_change.present? && status_change ==[0, 1]
        school = self.school
        if school.present? && school.teacher_role !=1
          school.update(teacher_role: 1)
        end
      end
    end
  end

  def role_type_3?
    role_type == 3
  end

  def role_type_2?
    role_type == 2
  end
end
