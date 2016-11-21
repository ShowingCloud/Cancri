module Api
  module V1
    class NotificationsController < Api::V1::ApplicationController
      before_action :authenticate!


      # 获取用户的通知列表
      # GET /api/v1/notifications

      def index
        optional! :page, default: 1
        optional! :per, default: 20, values: 1..150

        @notifications = Notification.where(user_id: current_user.id).order(:read).page(params[:page]).per(params[:per])

        render json: @notifications
      end

      # 将当前用户的某个通知设成已读状态
      # POST /api/v1/notifications/update_read

      def update_read
        requires! :id
        id = params[:id]
        if id.present?
          Notification.find(id).update(read: true)
        end

        render json: {ok: 1}
      end

      # 裁判获取比赛相关消息
      # POST /api/v1/notifications/comp_notify

      def comp_notify
        notifications = Notification.where(message_type: 6).where(['created_at > ?', 1.days.ago]).select(:id, :content)
        render json: {notifications: notifications}
      end


      ##
      # 获得未读通知数量
      #
      # GET /api/v1/notifications/unread_num
      #
      def unread_num
        render json: {num: current_user.notifications.unread.count}
      end

      ##
      # 删除当前用户的某个通知
      # DELETE /api/v1/notifications/:id
      #
      def destroy
        requires! :id
        @notification = current_user.notifications.find(params[:id])
        @notification.destroy
        render json: {ok: 1}
      end

      # 删除当前用户的所有通知
      #
      # DELETE /api/v1/notifications/all
      #
      def all
        current_user.notifications.delete_all
        render json: {ok: 1}
      end


    end
  end
end