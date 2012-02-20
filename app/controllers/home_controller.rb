class HomeController < ApplicationController
  
  def index
    redirect_to new_user_session_path
    # render layout: 'layout2'
  end
end
