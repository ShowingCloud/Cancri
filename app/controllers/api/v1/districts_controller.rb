module Api
  module V1
    class DistrictsController < Api::V1::ApplicationController

      def get_provinces
        render json: Province.select(:id, :name)
      end

      def get_cities
        requires! :province_id, type: Integer
        render json: City.where(province_id: params[:province_id]).select(:id, :name, :abbr).order(:abbr)
      end

      def get_districts
        requires! :city_id, type: Integer
        render json: City.where(city: params[:city_id]).select(:id, :name).order(:abbr)
      end

    end
  end
end