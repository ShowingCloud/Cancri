module Api
  module V1
    class RootController < Api::V1::ApplicationController
      def not_found
        raise ActiveRecord::RecordNotFound
      end
    end
  end
end
