class User::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: %i(create)

  # GET /resource/sign_up

  # POST /resource
  def create
    super do |user|
      sign_in(user)
    end
  end

  private

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: User::USER_PERMITTED)
  end
end
