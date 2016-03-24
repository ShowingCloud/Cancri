module API
  module V1
    class Scores < Grape::API
      resources :scores do
        desc '成绩属性'
        get '/' do
          score_attributes = ScoreAttribute.all.select(:id, :name)
          render score_attributes: score_attributes
        end
      end

    end
  end
end