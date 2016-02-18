class CompetitionsController < ApplicationController
  def index
    @competitions = Competition.all
  end

  def show
  end
end
