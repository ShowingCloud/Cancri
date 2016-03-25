module API
  module V1
    class Scores < Grape::API
      resources :scores do
        desc '获取成绩属性'
        params do
          optional :except, type: String
        end
        get '/' do
          except = params[:except].present? ? params[:except] : 0
          score_attributes = ScoreAttribute.where.not(id: except).select(:id, :name)
          render score_attributes: score_attributes
        end
      end

    end
  end
end