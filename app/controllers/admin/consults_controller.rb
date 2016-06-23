class Admin::ConsultsController < AdminController
  before_action :set_consult, only: [:edit, :update, :destroy]

  # GET /admin/consults
  # GET /admin/consults.json
  def index
    if params[:field].present? && params[:keyword].present?
      @consults = Consult.joins(:user).where(["consults.#{params[:field]} like ?", "%#{params[:keyword]}%"]).select(:id, :user_id, :content, :status, :unread, :admin_reply, :admin_id, 'users.nickname').page(params[:page]).per(params[:per])
    else
      @consults = Consult.joins(:user).where(status: 0, admin_reply: 0).select(:id, :user_id, :content, :status, :unread, :admin_reply, :admin_id, 'users.nickname').page(params[:page]).per(params[:per])
    end
  end

  # GET /admin/consults/1
  # GET /admin/consults/1.json
  def show
    @user_consults = Consult.joins(:user).where(user_id: params[:ud]).select(:id, :user_id, :content, :status, :unread, :admin_reply, :admin_id, 'users.nickname').page(params[:page]).per(params[:per])
  end

  # GET /admin/consults/new
  def new
    @consult = Consult.new
  end

  # GET /admin/consults/1/edit
  def edit
  end

  # POST /admin/consults
  # POST /admin/consults.json
  def create
    @consult = Consult.new(consult_params)


    respond_to do |format|
      if @consult.save
        if consult_params[:parent_id].present?
          Consult.find(consult_params[:parent_id]).update_attributes(status: true)
        end
        format.html { redirect_to "/admin/consults/#{@consult.id}?ud=#{@consult.user_id}", notice: '回复成功!' }
        format.json { render action: 'show', status: :created, location: @consult }
      else
        puts 'nihao'
        puts request.fullpath
        puts consult_params[:reply_content]
        format.html { redirect_to "/admin/consults/new?pd=#{consult_params[:parent_id]}&ud=#{consult_params[:user_id]}&content=#{consult_params[:reply_content]}", notice: '内容至少6个字符' }
        format.json { render json: @consult.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/consults/1
  # PATCH/PUT /admin/consults/1.json
  def update
    respond_to do |format|
      if @consult.update(consult_params)
        format.html { redirect_to [:admin, @consult], notice: t('activerecord.models.consult')+'更新成功!' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @consult.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/consults/1
  # DELETE /admin/consults/1.json
  def destroy
    @consult.destroy
    respond_to do |format|
      format.html { redirect_to admin_consults_url, notice: t('activerecord.models.consult')+'删除成功!' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_consult
    @consult = Consult.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def consult_params
    params.require(:consult).permit!
  end
end