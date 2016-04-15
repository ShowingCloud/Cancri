class NotificationsController < ApplicationController


  def create

    @notification = Notification.new(content: params[:content], user_id: current_user.id)

    respond_to do |format|
      if @notification.save
        format.js { render nothing: true }
      else
        format.js { render nothing: true }
      end
    end
  end
end
