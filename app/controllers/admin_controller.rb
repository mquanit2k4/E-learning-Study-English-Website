class AdminController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user
end
