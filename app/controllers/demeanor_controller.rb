class DemeanorController < ApplicationController
  def index
    @photos = Photo.all #.where(status: 1).all
  end

  def show
    @photo = Photo.find(params[:id])
  end
end