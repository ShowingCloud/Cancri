class NewsController < ApplicationController
  def index
    if params[:type].present?
      news = News.where(status: 1).where("locate(#{params[:type]},news_type)>0"); false
    else
      news = News.where(status: 1); false
    end
    if cookies[:area] == '1'
      news = news.where(district_id: 9)
    end
    @news = news.page(params[:page]).per(params[:per])
    if @news.length>0
      @news_array = @news.map { |n| {
          id: n.id,
          name: n.name,
          desc: n.desc,
          cover: n.cover_url,
          type: NewsType.find(n.news_type.split(',')).pluck(:name).join(' '),
          created_at: n.created_at
      } }
    end
  end

  def show
    @news = News.find(params[:id])
    @news_type = NewsType.find(@news.news_type.split(',')).pluck(:name).join(' ')
  end
end
