class VolunteersController < ApplicationController
  before_action :require_user, except: [:index]


  def index
    @competitions = Competition.where(status: 0)
  end

  def apply_comp_volunteer
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
    render json: result
  end
end
