# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user_guid

    def connect
      self.current_user_guid = find_verified_user
    end

    protected

    def find_verified_user
      cookies.signed[:user_id] || token_user(request.params[:token])
    end

    def token_user(token)
      if token.present?
        value = $redis.get("token-#{token}")
        if value.present?
          data = JSON.parse(value)
          data["id"]
        else
          nil
        end
      else
        nil
      end
    end

  end
end
