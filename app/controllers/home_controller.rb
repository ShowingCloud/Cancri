class HomeController < ApplicationController
  def index
    if cookies[:area]=='1'
      @area = '宝山'
    else
      @area = '上海'
    end
  end

  def error_404
    render_404
  end
end
