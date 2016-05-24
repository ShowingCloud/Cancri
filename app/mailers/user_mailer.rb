class UserMailer < ActionMailer::Base
  default from: Settings.email_form


  def user_add_email_code(email, code)
    @code = code
    email_with_name = "<#{email}>"
    # @url = 'http://example.com/login'
    mail(to: email_with_name, subject: '豆姆科技-添加安全邮箱')
  end

  def leader_invite_player(leader, invited_email, code, event, team_name, td)
    @code = code
    @leader = leader
    @team_name = team_name
    @t = td
    @event = event
    @email = invited_email
    email_with_name = "<#{invited_email}>"
    mail(to: email_with_name, subject: "#{leader}邀请你参加#{event}项目")
  end
end