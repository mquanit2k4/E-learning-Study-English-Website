class SessionsController < ApplicationController
  REMEMBER_ME_SELECTED = "1".freeze

  # GET /login
  def new; end

  # POST /login
  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase
    if user&.authenticate params.dig(:session, :password)
      handle_successful_login user
    else
      handle_failed_login
    end
  end

  # DELETE /logout
  def destroy
    log_out
    redirect_to root_url, status: :see_other
  end

  private

  def handle_successful_login user
    reset_session
    log_in user
    if params.dig(:session, :remember_me) == REMEMBER_ME_SELECTED
      remember user
    else
      remember_session user
    end
    flash[:success] = t(".login_success")
    redirect_to user, status: :see_other
  end

  def handle_failed_login
    flash.now[:danger] = t(".invalid_email_or_password")
    render :new, status: :unprocessable_entity
  end
end
