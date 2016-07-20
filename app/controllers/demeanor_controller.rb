class DemeanorController < ApplicationController
  def index
    photos = Photo.where(status: 1).order('id desc').page(params[:page]).per(params[:per]); false
    if params[:cd]
      @photos = photos.where(competition_id: params[:cd])
    else
      @photos = photos
    end
  end

  def videos
    if params[:cd]
      @videos = Video.where(status: 1, competition_id: params[:cd]).order('id desc').page(params[:page]).per(params[:per])
    else
      @videos = Video.where(status: 1).order('id desc').page(params[:page]).per(params[:per])
    end
  end

  def get_comps_via_year
    render json: @competitions = Competition.where(status: [2, 3], host_year: params[:host_year]).select(:id, :name)
  end

  def show
  end
end