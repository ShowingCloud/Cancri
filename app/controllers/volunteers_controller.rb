class VolunteersController < ApplicationController
  before_action :require_user, except: [:index, :show]
  before_action :require_mobile, :only => [:apply_comp_volunteer]


  def index
    @volunteers = Volunteer.all.page(params[:page]).per(params[:per])
  end

  def show
    @volunteer = Volunteer.find(params[:id])
  end

  def apply_comp_volunteer
    username = params[:username]
    school = params[:school].to_i
    age= params[:age].to_i
    grade= params[:grade]
    if /\A[\u4e00-\u9fa5]{2,4}\Z/.match(username)==nil
      result = [false, '姓名为2-4位中文']
    else
      if username.present? && school !=0 && age != 0 && grade.present? && UserProfile.update_attributes!(username: username, school: school, age: age, grade: grade)
        if params[:comp_id].present?
          cw = CompWorker.where(competititon_id: params[:comp_id], user_id: current_user.id).exists?
          if cw
            result=[false, '您已经申请']
          else
            comp_worker = CompWorker.create!(competititon_id: params[:comp_id], user_id: current_user.id)
            if comp_worker.save
              result=[true, '申请成功,等待审核']
            else
              result=[false, '申请失败']
            end
          end
        else
          result=[false, '参数不完整']
        end
      else
        result=[false, '个人信息填写不规范']
      end
    end
    render json: result
  end
end
