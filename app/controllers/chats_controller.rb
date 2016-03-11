class ChatsController < ApplicationController
  before_action :set_chat, only: [:show, :edit, :update, :destroy]

  # GET /chats
  # GET /chats.json
  #
  before_action do
    @channel = '/channel'
    if params[:roomid].present?
      @channel += '/' + params[:roomid]
    end
  end

  before_action do
    $chats ||= {}
    $chats[@channel] ||= []
  end


  def index
  end

  # GET /chats/1
  # GET /chats/1.json
  def show
  end

  # GET /chats/new
  def new
    @chat = Chat.new
  end

  # GET /chats/1/edit
  def edit
  end

  # POST /chats
  # POST /chats.json
  def create
    chat = {content: params[:content], time: Time.now}
    $chats[@channel] << chat

    MessageBus.publish @channel, chat

    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Chat was successfully created.' }
      format.js { render nothing: true }
    end
  end

  # PATCH/PUT /chats/1
  # PATCH/PUT /chats/1.json
  def update
    respond_to do |format|
      if @chat.update(chat_params)
        format.html { redirect_to @chat, notice: 'Chat was successfully updated.' }
        format.json { render :show, status: :ok, location: @chat }
      else
        format.html { render :edit }
        format.json { render json: @chat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chats/1
  # DELETE /chats/1.json
  def destroy
    @chat.destroy
    respond_to do |format|
      format.html { redirect_to chats_url, notice: 'Chat was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_chat
    @chat = Chat.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def chat_params
    params[:chat]
  end
end
