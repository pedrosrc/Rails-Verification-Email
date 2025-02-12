class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      if user.verified?
        session[:user_id] = user.id
        redirect_to user, notice: "Login successful!"
      else
        redirect_to verify_user_path(user), alert: "Verify your account first!"
      end
    else
      flash.now[:alert] = "Email or password is wrong"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to new_session_path, notice: "You are out of account!"
  end
end
