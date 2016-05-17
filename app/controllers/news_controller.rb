class NewsController < ApplicationController
  def index
    if params[:type].present?
      @news = News.where("locate(#{params[:type]},news_type)>0").page(params[:page]).per(params[:per])
    else
      @news = News.all.page(params[:page]).per(params[:per])
    end
    if @news.length>0
      @news_array = @news.map { |n| {
          id: n.id,
          name: n.name,
          content: n.content,
          type: NewsType.find(n.news_type.split(',')).pluck(:name).join(' '),
          created_at: n.created_at
      } }
    end
  end

  def show
    @new = News.find(params[:id])
    @new_type = NewsType.find(@new.news_type.split(',')).pluck(:name).join(' ')
  end
end
