class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      if user.verified?
        session[:user_id] = user.id
        redirect_to user, notice: "Login realizado com sucesso!"
      else
        redirect_to verify_user_path(user), alert: "Verifique sua conta primeiro!"
      end
    else
      flash.now[:alert] = "Email ou senha inválidos"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to new_session_path, notice: "Você saiu da conta!"
  end
end
