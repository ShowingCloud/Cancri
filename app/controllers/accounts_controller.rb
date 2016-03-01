class AccountsController < ApplicationController
  def index
  end


  def reset_password
    if @current_user.present?
      redirect_to root_path
      return
    end
    @reset_password = ResetPassword.new
  end

  def reset_password_post
    if @current_user.present?
      redirect_to root_path
      return
    end
    @reset_password = ResetPassword.new(params[:reset_password])
    if @reset_password.save
      flash[:success] = '密码已经成功重置'
      redirect_to root_path
    else
      render :reset_password
    end
  end

  def validate_captcha
    if request.method == 'POST'
      if verify_rucaptcha? (params[:captcha])
        result = [true, '校验码正确']
      else
        result = [false, '校验码输入错误']
      end
    else
      result = [false, '非法请求']
    end
    render json: result
  end

  private

  def redirect_to_url
    if cookies[:redirect_url].present?
      redirect_url = cookies[:redirect_url]
      cookies[:redirect_url] = nil
      redirect_to redirect_url
    else
      redirect_to root_path
    end
  end
end