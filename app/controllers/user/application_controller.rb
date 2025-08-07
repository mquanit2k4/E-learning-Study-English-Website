class User::ApplicationController < ApplicationController
  before_action :logged_in_user
  before_action :ensure_user_role
end
