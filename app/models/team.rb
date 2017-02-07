class Team < ApplicationRecord
  belongs_to :user
  belongs_to :event
  belongs_to :district
  belongs_to :school
  has_many :team_user_ships, :dependent => :destroy
  has_many :users, through: :team_user_ship
  # has_many :invites
  mount_uploader :cover, CoverUploader

  GROUP = {primary: 1, middle: 2, junior: 3, high: 4}
  # validates :name, presence: true, length: {in: 2..5}, format: {with: /\A[\u4e00-\u9fa5_a-zA-Z0-9]+\Z/i, message: '队伍名称只能包含中文、数字、字母、下划线'}, uniqueness: {scope: :event_id, message: '同一个项目的队伍名称不能重复'}
  validates :user_id, presence: true
  validates :status, presence: true
  # validates :district_id, presence: true
  validates :group, inclusion: [1, 2, 3, 4], presence: true
  validates :event_id, presence: true, uniqueness: {scope: :user_id, message: '一个用户不能报名一个项目两次'}
  validates :teacher, presence: true #, format: {with: /\A[\u4e00-\u9fa5]{2,10}\Z/i, message: '只能包含2-10位中文'}
  validates :teacher_mobile, allow_blank: true, format: {with: /\A1[34578][0-9]{9}\Z/i, message: '格式不正确'}
  validates :team_code, length: {in: 4..6}, allow_blank: true
  after_create_commit :create_identifier
  after_update_commit :notify_after_status_update

  protected

  def notify_after_status_update
    # status_change = attribute_previous_change(:status)
    # if status_change.present? && status_change !=[0, 2]
    #   NotifyJob.perform_async(id, identifier, user_id, players, status_change)
    # end
    if status_changed? && status_change == [0, 2]
      NotifyJob.perform_async(id, identifier, user_id, players, [0, 2])
    end
  end

  def create_identifier
    unless identifier.present?
      case group
        when 1 then
          identity = 'X'
        when 2 then
          identity = 'Z'
        when 3 then
          identity = 'J'
        when 4 then
          identity = 'S'
        else
          identity = 'W'
      end
      ((id+128000).to_s).each_byte do |c|
        if c != 48
          identity.concat((c.to_i + 16).chr)
        else
          identity.concat('O')
        end
      end
      self.identifier = identity
      self.save
    end
  end
end
