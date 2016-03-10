class AuthController < ApplicationController
  before_action :authenticate_user_from_token!, :except => [:access_token]

  before_action :authenticate_user!, :except => [:access_token]
  skip_before_action :verify_authenticity_token, :only => [:access_token]

  def authorize

    AccessGrant.prune!
    create_hash = {
        client: application,
        state: params[:state]
    }
    access_grant = current_user.access_grants.create(create_hash)
    redirect_to access_grant.redirect_uri_for(params[:redirect_uri])
  end

  # POST
  def access_token
    application = Client.authenticate(params[:client_id], params[:client_secret])

    if application.nil?
      render :json => {:error => "没有该应用"}
      return
    end

    access_grant = AccessGrant.authenticate(params[:code], application.id)
    if access_grant.nil?
      render :json => {:error => "Could not authenticate access code"}
      return
    end

    access_grant.start_expiry_period!
    render :json => {:access_token => access_grant.access_token, :refresh_token => access_grant.refresh_token, :expires_in => 1.day.to_i}
  end

  def user
    if params[:oauth_token].present?
      hash = {
          provider: 'login',
          id: current_user.id.to_s,
          info: {
              email: current_user.email,
              private_token: current_user.private_token
          },
          extra: {
              nickname: current_user.nickname
          }

      }
    else
      hash={error: '非法请求'}
    end

    render :json => hash.to_json
  end

  protected

  def application
    @application ||= Client.find_by_app_id(params[:client_id])
  end

  private

  def authenticate_user_from_token!
    if params[:oauth_token]
      access_grant = AccessGrant.where(access_token: params[:oauth_token]).take
      if access_grant.user
        sign_in access_grant.user
      end
    end
  end
end


