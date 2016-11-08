class HomeController < ApplicationController
  def index
    competition = Competition.where.not(status: 0).select(:id, :name, :cover).order('created_at desc')
    activity = Activity.where(status: 1, level: 1).select(:id, :name, :cover)

    if cookies[:area] == '1'
      competition = competition.where(district_id: 9)
      activity = activity.where(district_id: 9)
    end

    @competition = competition.limit(2)
    @activity = activity.last
  end

  def error_404
    render_optional_error(404)
  end
end
