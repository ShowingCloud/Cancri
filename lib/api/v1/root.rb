module API
  require 'doorkeeper/grape/helpers'

  module V1
    class Root < Grape::API
      version 'v1'
      prefix 'api'

      default_error_formatter :json
      content_type :json, 'application/json'
      format :json
      # formatter :json, Grape::Formatter::ActiveModelSerializers

      rescue_from :all do |e|
        case e
          when ActiveRecord::RecordNotFound
            Rack::Response.new([{error: '数据不存在'}.to_json], 404, {}).finish
          when Grape::Exceptions::ValidationErrors
            Rack::Response.new([{
                                    error: '参数不符合要求，请检查参数是否按照 API 要求传输。',
                                    validation_errors: e.full_messages
                                }.to_json], 400, {}).finish
          else
            # ExceptionNotifier.notify_exception(e) # Uncommit it when ExceptionNotification is available
            if Rails.env.test?
              Rails.logger.error "Error: #{e}\n#{e.backtrace[0, 3].join("\n")}"
            else
              Rails.logger.error "Api V1 Error: #{e}\n#{e.backtrace.join("\n")}"
            end
            Rack::Response.new([{error: "API 接口异常"}.to_json], 500, {}).finish
        end
      end

      helpers Doorkeeper::Grape::Helpers
      helpers API::V1::Helpers


      mount API::V1::Users
      add_swagger_documentation api_version: 'v1',
                                hide_documentation_path: true,
                                mount_path: '/docs',
                                hide_format: true


    end
  end
end
