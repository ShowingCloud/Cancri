class UserMailer < ActionMailer::Base
  default from: Settings.email_form


  def user_add_email_code(email, code)
    @code = code
    email_with_name = "<#{email}>"
    # @url = 'http://example.com/login'
    mail(to: email_with_name, subject: '豆姆科技-添加安全邮箱')
  end
end