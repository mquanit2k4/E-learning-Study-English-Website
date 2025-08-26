class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin

  private

  def authenticate_admin
    return if current_user&.admin?

    flash[:danger] = t("errors.access_denied")
    redirect_to(root_path)
  end
end
