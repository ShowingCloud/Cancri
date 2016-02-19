class CompetitionsController < ApplicationController

  before_action :set_competition, only: [:show]

  def index
    @competitions = Competition.all
  end

  def show
  end

  def apply_comp

  end

  protected

  def set_competition
    @competition = Competition.find(params[:id])
  end
end
