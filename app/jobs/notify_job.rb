class NotifyJob
  include Sidekiq::Worker
  sidekiq_options queue: 'notifications'

  def perform(id, identifier, user_id, players, status_change)
    user_ids = [user_id]
    if players > 1
      user_ids = TeamUserShip.where(team_id: id).pluck(:user_id)
    end

    case status_change
      when [2, -2] then
        content = '您所在的队伍:'+ identifier +',被学校老师 拒绝 参加比赛!'
      when [-2, 3] then
        content = '您所在的队伍:'+ identifier +',被学校老师 允许 参加比赛!'
      when [3, 1] then
        content = '您所在的队伍:'+ identifier +',被区县老师 允许 参加比赛,报名正式成功!'
      when [3, -3] then
        content = '您所在的队伍:'+ identifier +',被区县老师 拒绝 参加比赛!'
      else
        content=''
    end
    if content.present? && user_ids.present?
      user_ids.each do |n|
        Notification.create(user_id: n, content: content, message_type: 0)
      end
    end
  end
end