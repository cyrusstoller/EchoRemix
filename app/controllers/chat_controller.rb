class ChatController < ApplicationController
  def index
    @title = "Chat"
    @logo_class = "small"
    @no_footer = true
    @nickname = cookies.signed['nickname']

    if @nickname.blank?
      flash[:error] = "Sorry you need to have a nickname to enter a chat."
      redirect_to root_path
    else
      render layout: 'empty'
    end
  end

  def create
    nickname = params[:nickname].to_s

    if nickname =~ /system/i
      flash[:error] = "You cannot call yourself 'System'"
      redirect_to root_path
    else
      cookies.signed[:nickname] = nickname
      cookies.signed[:uuid] = SecureRandom.uuid
      redirect_to action: "index"
    end
  end
end
