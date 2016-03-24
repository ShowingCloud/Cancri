class Admin::EventsController < AdminController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  before_action do
    authenticate_permissions(['editor', 'admin'])
  end

  # GET /admin/events
  # GET /admin/events.json
  def index
    if params[:field].present? && params[:keyword].present?
      @events = Event.all.where(["#{params[:field]} like ?", "%#{params[:keyword]}%"]).page(params[:page]).per(params[:per])
    else
      @events = Event.all.page(params[:page]).per(params[:per])
    end
  end

  # GET /admin/events/1
  # GET /admin/events/1.json
  def show
    # @users = User.where(validate_status: 1)
    @score_attributes = EventSaShip.where(event_id: params[:id])
  end


  # GET /admin/events/new
  def new
    @event = Event.new
  end

  # GET /admin/events/1/edit
  def edit
  end

  def add_score_attributes
    if request.method == 'POST'
      ed = params[:ed]
      sa_ids = params[:sa_ids]
      if sa_ids.present?
        respond_to do |format|
          sa_ids.each do |sa_id|
            esa = EventSaShip.where(event_id: ed, score_attribute_id: sa_id).take
            unless esa.present?
              EventSaShip.create!(event_id: ed, score_attribute_id: sa_id)
            end
          end
          [status: TRUE]
          flash[:notice]= '所选属性已成功添加'
          format.html {
            render json: status
          }
        end
      end
    end
  end

  def delete_score_attribute
    if params[:sa_id].present? && EventSaShip.delete(params[:sa_id])
      result = [true, '删除成功']
    else
      result = [false, '删除失败']
    end
    render json: result
  end

  # POST /admin/events
  # POST /admin/events.json
  def create
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to [:admin, @event], notice: '比赛项目创建成功' }
        format.json { render action: 'show', status: :created, location: @event }
      else
        format.html { render action: 'new' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /admin/events/1
  # PATCH/PUT /admin/events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to [:admin, @event], notice: '比赛项目更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/events/1
  # DELETE /admin/events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to admin_events_url, notice: '比赛项目删除成功' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit!
  end
end
