class PasswordResetsController < ApplicationController
  before_action :get_user, :valid_user, :check_expiration, only: %i(edit update)

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "send_reset_email_message"
      redirect_to root_url
    else
      flash[:danger] = t "email_reset_not_found"
      redirect_to new_password_reset_url
    end
  end

  def edit; end

  def update
    if params[:user][:password].blank?
      @user.errors.add :password, t("password_empty_errors")
      render :edit
    elsif @user.update user_params
      log_in @user
      flash[:success] = t "password_reset_success"
      redirect_to @user
    else
      flash[:danger] = t "password_reset_error"
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def get_user
    @user = User.find_by email: params[:email]
    return if @user

    flash[:danger] = t "error_loaded"
    redirect_to root_url
  end

  def valid_user
    return if @user&.activated? && @user.authenticated?(:reset, params[:id])

    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t "password_expired"
    redirect_to new_password_reset_url
  end
end
