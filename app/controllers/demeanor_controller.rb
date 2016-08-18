class DemeanorController < ApplicationController
  def index
    comp_id = params[:cd]
    photos = Photo.left_joins(:competition).where(status: 1).order('competition_id'); false
    if cookies[:area] == '1'
      photos = photos.where('competitions.district_id = ?', 9)
    end
    if comp_id
      photos = photos.where(competition_id: comp_id)
    end
    @photos = photos.select('photos.*', 'competitions.name as comp_name').page(params[:page]).per(params[:per])
  end

  def videos
    comp_id = params[:cd]
    videos = Video.left_joins(:competition).where(status: 1).order('competition_id'); false
    if cookies[:area] == '1'
      videos = videos.where('competitions.district_id = ?', 9)
    end
    if comp_id
      videos = videos.where(competition_id: comp_id)
    end
    @videos = videos.select('videos.*', 'competitions.name as comp_name').page(params[:page]).per(params[:per])
  end

  def get_comps_via_year
    render json: @competitions = Competition.where(status: [2, 3], host_year: params[:host_year]).select(:id, :name)
  end

  def show
  end
end