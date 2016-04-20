class InvitePlayer

  include Virtus::Model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :email, String
  attribute :code, String
  attribute :leader, String
  attribute :team_name, String
  attribute :nickname, String
  attribute :password, String
  attribute :password_confirmation, String
  attribute :username, String
  attribute :school, Integer
  attribute :gender, Integer
  attribute :student_code, String
  attribute :grade, String


  validates :email, presence: true, format: {with: /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/, message: '邮箱格式不正确'}
  validates :password, presence: true, length: {in: 6..30}, format: {with: /\A[\x21-\x7e]+\Z/i, message: '密码只能包含数字、字母、特殊字符'}
  # validates :password_confirmation, presence: true
  validates :nickname, presence: true, length: {in: 2..10}, format: {with: /\A[\u4e00-\u9fa5_a-zA-Z0-9]+\Z/i, message: '昵称只能包含中文、数字、字母、下划线'}
  validates :username, presence: true, length: {in: 2..5}, format: {with: /\A[\u4E00-\u9FA5]+\Z/i, message: '姓名只能为中文汉字'}
  validates :school, presence: true
  validates :grade, presence: true
  validates :gender, presence: true
  validates :student_code, presence: true
  validate :email_validation
  # validate :password_validation

  def email_validation
    if User.where(email: email).exists?
      errors[:email] << "该邮箱已被使用,请使用此邮箱登录申请加入该队"
    end
  end

  # def password_validation
  #   unless self.password == self.password_confirmation
  #     errors[:password_confirmation] << "与新密码不一致"
  #   end
  # end


  def persisted?
    FALSE
  end

  def save
    if valid?
      u = User.create!(nickname: nickname, password: password, email: email)
      if u.save
        u_p = UserProfile.create!(username: username, user_id: u.id, school: school.to_i, grade: grade, student_code: student_code, gender: gender.to_i)
        if u_p.save
          team = Invite.joins(:team).where(email: email, code: code).where("teams.id=invites.team_id").select(:team_id, "teams.event_id as event_id").take
          t_u = TeamUserShip.create!(team_id: team.team_id, event_id: team.event_id, user_id: u.id)
          t_u.save
        end
      else
        u.delete
      end
    else
      nil
    end
  end

end