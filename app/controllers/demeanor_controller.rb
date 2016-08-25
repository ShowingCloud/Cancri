class DemeanorController < ApplicationController
  def index
    comp_id = params[:cd]
    photos = Photo.joins('left join competitions c on c.id = photos.type_id').where(status: 1, photo_type: 0).order('type_id'); false
    if cookies[:area] == '1'
      photos = photos.where('c.district_id = ?', 9)
    end
    if comp_id
      photos = photos.where(type_id: comp_id)
    end
    @photos = photos.select('photos.*', 'c.name as comp_name').page(params[:page]).per(params[:per])
  end

  def videos
    comp_id = params[:cd]
    videos = Video.joins('left join competitions c on c.id = videos.type_id').where(status: 1, video_type: 0).order('type_id'); false
    if cookies[:area] == '1'
      videos = videos.where('c.district_id = ?', 9)
    end
    if comp_id
      videos = videos.where(type_id: comp_id)
    end
    @videos = videos.select('videos.*', 'c.name as comp_name').page(params[:page]).per(params[:per])
  end

  def get_comps_via_year
    render json: @competitions = Competition.where(status: [2, 3], host_year: params[:host_year]).select(:id, :name)
  end

  def show
  end
end