class NewsController < ApplicationController
  def index
    @news = News.all.page(params[:page]).per(params[:per])
  end

  def show
    @new = News.find(params[:id])
  end
end
