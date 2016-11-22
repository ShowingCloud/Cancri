class Admin::NotificationsController < AdminController
  before_action :set_notification, only: [:show, :edit, :update, :destroy]

  # GET /admin/notifications
  # GET /admin/notifications.json
  def index
    if params[:field].present? && params[:keyword].present?
      @notifications = Notification.where(message_type: 6).where(["#{params[:field]} like ?", "%#{params[:keyword]}%"]).page(params[:page]).per(params[:per])
    else
      @notifications = Notification.where(message_type: 6).page(params[:page]).per(params[:per])
    end

  end

  # GET /admin/notifications/1
  # GET /admin/notifications/1.json
  def show
  end

  # GET /admin/notifications/new
  def new
    @notification = Notification.new
  end

  # GET /admin/notifications/1/edit
  def edit
  end

  # POST /admin/notifications
  # POST /admin/notifications.json
  def create
    @notification = Notification.new(notification_params)

    respond_to do |format|
      if @notification.save
        format.html { redirect_to [:admin, @notification], notice: '消息创建成功' }
        format.json { render action: 'show', status: :created, location: @notification }
      else
        format.html { render action: 'new' }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/notifications/1
  # PATCH/PUT /admin/notifications/1.json
  def update
    respond_to do |format|
      if @notification.update(notification_params)
        format.html { redirect_to [:admin, @notification], notice: '消息更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/notifications/1
  # DELETE /admin/notifications/1.json
  def destroy
    @notification.destroy
    respond_to do |format|
      format.html { redirect_to admin_notifications_url, notice: '消息删除成功' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_notification
    @notification = Notification.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def notification_params
    params.require(:notification).permit!
  end
end
