class HomeController < ApplicationController
  def index
    @recent_activities = Activity.select(:id, :name, :cover).limit(3)
  end

  def error_404
    render_404
  end
end
