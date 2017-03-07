class Admin::EventVolPositionsController < AdminController
  before_action :set_event_vol_position, only: [:show, :edit, :update, :destroy]

  # GET /admin/event_vol_positions
  # GET /admin/event_vol_positions.json
  def index
    positions = EventVolPosition.all
    if params[:field].present? && params[:keyword].present?
      positions = positions.where(["#{params[:field]} like ?", "%#{params[:keyword]}%"])
    end
    @event_vol_positions = positions.page(params[:page]).per(params[:per])
  end

  # GET /admin/event_vol_positions/1
  # GET /admin/event_vol_positions/1.json
  def show
  end

  # GET /admin/event_vol_positions/new
  def new
    @event_vol_position = EventVolPosition.new
  end

  # GET /admin/event_vol_positions/1/edit
  def edit
  end

  # POST /admin/event_vol_positions
  # POST /admin/event_vol_positions.json
  def create
    names = params[:positions]
    event_volunteer_id = params[:event_volunteer_id]

    if names.is_a?(Array) && names.length < 4 && event_volunteer_id.present?
      result_status = true
      result = []
      success_positions = []
      each_index = 0
      names.each_with_index do |position, index|
        each_index = index
        if result_status
          begin
            EventVolPosition.transaction do
              evp = EventVolPosition.create!(name: position, event_volunteer_id: event_volunteer_id)
              result << "#{position}!"
              success_positions << {name: position, id: evp.id}
            end
          rescue Exception => ex
            result_status = false
            result << ex.message
          end
        else
          break
        end
      end
      if result_status
        result = [true, '提交成功', success_positions]
      else
        if each_index > 0
          result = [true, (result[0..-2]+['剩余职位添加失败']).join(','), success_positions]
        else
          result = [false, result[0]]
        end
      end
    else
      result = [false, '参数不完整']
    end

    respond_to do |format|
      format.json { render json: {status: result[0], message: result[1], success_positions: result[2]} }
      if result[0]
        format.html { redirect_to [:admin, @event_vol_position], notice: @event_vol_position.name+'创建成功' }

      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /admin/event_vol_positions/1
  # PATCH/PUT /admin/event_vol_positions/1.json
  def update
    respond_to do |format|
      if @event_vol_position.update(event_vol_position_params)
        format.html { redirect_to [:admin, @event_vol_position], notice: @event_vol_position.name+'更新成功' }
        format.json { head :no_content }
        format.js
      else
        format.html { render action: 'edit' }
        format.json { render json: @event_vol_position.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /admin/event_vol_positions/1
  # DELETE /admin/event_vol_positions/1.json
  def destroy
    # evp = EventVolPosition.find(params[:id])
    @event_vol_position.destroy
    respond_to do |format|
      format.html { redirect_to admin_positions_url, notice: @event_vol_position.name + '已成功删除.' }
      format.json { head :no_content }
      format.js
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_event_vol_position
    @event_vol_position = EventVolPosition.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_vol_position_params
    params.require(:event_vol_position).permit(:name, :status, :event_volunteer_id)
  end


end
