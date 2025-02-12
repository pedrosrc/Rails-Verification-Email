class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      UserMailer.verification_email(@user).deliver_now
      redirect_to verify_user_path(@user), notice: "Code sent to your email."
    else
      render :new, status: :unprocessable_entity, notice: "Try again"
    end
  end

  def verify
    @user = User.find(params[:id])
  end

  def confirm_verification
    @user = User.find(params[:id])
    if @user.verification_code == params[:verification_code]
      @user.update(verified: true, verification_code: nil)
      redirect_to new_session_path, notice: "Account verified! Log in."
    else
      flash.now[:alert] = "Code invalid!"
      render :verify, status: :unprocessable_entity
    end
  end

  def resend_verification_code
    @user = User.find(params[:id])
    @user.update(verification_code: rand(100000..999999).to_s)
    UserMailer.verification_email(@user).deliver_now

    redirect_to verify_user_path(@user), notice: "New code sent to your email."
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
