class User::ApplicationController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_user_access

  private

  def ensure_user_access
    authorize! :access, :user
  end
end
