class SessionsController < ApplicationController

  def create
    auth_hash = request.env['omniauth.auth']
    if auth_hash["uid"]
      @user = User.find_or_create_from_omniauth(auth_hash)
      if @user
        session[:user_id] = @user.id
        redirect_to root_path
      else
        redirect_to root_path, notice: "Incorrect email or password"
      end
    else
      redirect_to root_path, notice: "Incorrect email or password"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to new_session_path, notice: "You've logged out. See you next time."
  end
end
