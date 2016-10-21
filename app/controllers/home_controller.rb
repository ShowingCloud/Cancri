class HomeController < ApplicationController
  def index
    puts session.id
    competition = Competition.where.not(status: 0); false
    activity = Activity.where(status: 1, level: 1); false

    if cookies[:area] == '1'
      competition = competition.where(district_id: 9)
      activity = activity.where(district_id: 9)
    end

    @competition = competition.order('id asc').limit(2)
    @activity = activity.last
  end

  def error_404
    render_optional_error(404)
  end
end
