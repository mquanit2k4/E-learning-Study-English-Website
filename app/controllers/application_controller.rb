class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include SessionsHelper

  include Pagy::Backend

  before_action :set_locale

  def set_locale
    allowed = I18n.available_locales.map(&:to_s)

    I18n.locale =
      if allowed.include?(params[:locale])
        params[:locale]
      else
        I18n.default_locale
      end
  end

  def default_url_options
    {locale: I18n.locale}
  end

  private

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t(".please_log_in")
    redirect_to login_url
  end
end
