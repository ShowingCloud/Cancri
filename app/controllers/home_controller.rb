class HomeController < ApplicationController
  def index
    @competition = Competition.where.not(status: 0).limit(2)
    @activity = Activity.where(status: 1).last
  end

  def error_404
    render_optional_error(404)
  end
end
