class NewsController < ApplicationController
  def index
    if params[:type].present?
      @news = News.where("locate(#{params[:type]},news_type)>0").page(params[:page]).per(params[:per])
    else
      @news = News.all.page(params[:page]).per(params[:per])
    end
  end

  def show
    @new = News.find(params[:id])
  end
end
