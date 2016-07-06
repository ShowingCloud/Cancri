class HomeController < ApplicationController
  def index
  end

  def error_404
    render_optional_error(404)
  end
end
