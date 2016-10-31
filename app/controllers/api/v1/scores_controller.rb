module Api
  module V1
    class ScoresController < Api::V1::ApplicationController

      ##
      # 获取成绩属性列表
      #
      # GET /api/v1/scores
      #
      def index
        optional! :except
        except = params[:except].present? ? params[:except] : 0
        score_attributes = ScoreAttribute.where.not(id: except).select(:id, :name, :write_type)
        render json: score_attributes
      end

    end
  end
end
