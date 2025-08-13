class UsersController < ApplicationController
  before_action :logged_out_user, only: %i(new create)
  before_action :logged_in_user,
                :load_user,
                :ensure_user_role,
                :correct_user, only: %i(show edit update)

  # GET /users/:id
  def show
    @pagy, @user_courses = pagy(
      @user.user_courses
          .with_course
          .with_status(params[:status])
          .recent,
      limit: Settings.page_6
    )
  end

  # GET /signup
  def new
    @user = User.new
  end

  # POST /signup
  def create
    @user = User.new user_params
    if @user.save
      reset_session
      log_in @user
      flash[:success] = t(".created")
      redirect_to @user, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /users/:id/edit
  def edit; end

  # PATCH/PUT /users/:id
  def update
    if @user.update user_params
      flash[:success] = t(".updated")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t(".not_found")
    redirect_to root_path
  end

  def correct_user
    return if current_user? @user

    flash[:error] = t(".cannot_edit")
    redirect_to root_url
  end

  def user_params
    params.require(:user).permit(User::USER_PERMITTED)
  end
end
