module Api
  module V1
    class ApplicationController < ActionController::API
      include ::ActionController::Cookies
      include ::ActionController::MimeResponds
      include ::ActionController::Flash
      class ParameterValueNotAllowed < ActionController::ParameterMissing
        attr_reader :values

        def initialize(param, values)
          @param = param
          @values = values
          super("param: #{param} value only allowed in: #{values}")
        end
      end

      class AccessDenied < StandardError;
      end
      class PageNotFound < StandardError;
      end

      rescue_from(ActionController::ParameterMissing) do |err|
        render json: {error: 'ParameterInvalid', message: err}, status: 400
      end
      rescue_from(ActiveRecord::RecordInvalid) do |err|
        render json: {error: 'RecordInvalid', message: err}, status: 400
      end
      rescue_from(AccessDenied) do |err|
        render json: {error: 'AccessDenied', message: err}, status: 403
      end
      rescue_from(ActiveRecord::RecordNotFound) do
        render json: {error: 'ResourceNotFound'}, status: 404
      end

      def requires!(name, opts = {})
        opts[:require] = true
        optional!(name, opts)
      end

      def optional!(name, opts = {})
        if params[name].blank? && opts[:require] == true
          raise ActionController::ParameterMissing.new(name)
        end

        if opts[:values] && params[name].present?
          values = opts[:values].to_a
          if !values.include?(params[name]) && !values.include?(params[name].to_i)
            raise ParameterValueNotAllowed.new(name, opts[:values])
          end
        end

        if params[name].blank? && opts[:default].present?
          params[name] = opts[:default]
        end
      end

      def error!(data, status_code = 400)
        render json: data, status: status_code
      end

      def error_404!
        error!({error: 'Page not found'}, 404)
      end

      def current_user
        @current_user ||= local_or_token_authenticate
      end

      def authenticate!
        error!({error: '401 Unauthorized'}, 401) unless current_user
      end

      def current_admin
        @current_admin ||= Admin.authenticated_access_token(cookies[:access_token])
      end

      def authenticate_admin
        error!({error: '401 Unauthorized'}, 401) unless current_admin
      end

      def local_or_token_authenticate
        if request.headers["auth-token"].present?
          value = $redis.get("token-#{request.headers["auth-token"]}")
          if value.present?
            data = JSON.parse(value)
          else
            return nil
          end
          User.find(data["id"])
        else
          warden.authenticate(scope: :user)
        end
      end

    end
  end
end
