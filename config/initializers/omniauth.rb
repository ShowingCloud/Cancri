Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas, url: Settings.auth_url, on_single_sign_out:Proc.new{
    |request|  saml = Nokogiri.parse(request.params['logoutRequest'])
                sess_idx = saml.xpath('//samlp:SessionIndex').text
                data = $redis.get("ticket-#{sess_idx}")
                json = JSON.parse(data)
                if json["token"].present?
                  $redis.del "token-#{json["token"]}"
                end
                session_id = json["session_id"]
                app = Rails.application.app
                begin
                   app = (app.instance_variable_get(:@backend) || app.instance_variable_get(:@app) || app.instance_variable_get(:@target))
                end until app.nil? or app.class == ActionDispatch::Session::RedisStore
                app.instance_variable_get(:@pool).del(session_id)
                Rails.logger.info "session #{session_id} destory"
  }
end
