class User::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      handle_google_success(@user)
    else
      handle_google_failure
    end
  end

  private

  def handle_google_success user
    flash[:success] = t("devise.omniauth_callbacks.google_oauth2.success")
    sign_in_and_redirect user, event: :authentication
  end

  def handle_google_failure
    session["devise.google_data"] = request.env["omniauth.auth"].except("extra")
    flash[:danger] = t("devise.omniauth_callbacks.google_oauth2.failure")
    redirect_to new_user_session_path
  end
end
