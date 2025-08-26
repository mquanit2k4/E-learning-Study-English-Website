class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include Pagy::Backend

  before_action :set_locale

  rescue_from CanCan::AccessDenied do |_exception|
    flash[:danger] = t("errors.access_denied")
    redirect_to root_path
  end

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

  def respond_modal_with(*args, &)
    options = args.extract_options!
    options[:responder] = ModalResponder
    respond_with(*args, options, &)
  end

  private

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end
end
