module API
  module V1
    module Helpers
      # Monkey patch grape-active_model_serializers to avoid duplicate db query
      def render(result, options = {})
        if result.is_a?(ActiveRecord::Relation)
          super(result.to_a, options)
        else
          super(result, options)
        end
      end

      # topic helpers
      def max_page_size
        100
      end

      def default_page_size
        15
      end

      def page_size
        size = params[:size].to_i
        [size.zero? ? default_page_size : size, max_page_size].min
      end

      # user helpers
      def current_user
        # @current_user ||= User.find_by_id(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end

      def authenticate!
        error!({'error' => '401 Unauthorized'}, 401) unless current_user
      end

      def owner?(obj)
        return false if current_user.blank?
        return false if obj.blank?

        if obj.is_a?(User)
          return obj.id == current_user.id
        else
          return obj.user_id == current_user.id
        end
      end


      def error_404!
        error!({'error' => 'Page not found'}, 404)
      end

      private

    end
  end
end
