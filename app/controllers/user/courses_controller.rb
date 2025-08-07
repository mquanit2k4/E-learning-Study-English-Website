class User::CoursesController < User::ApplicationController
  skip_before_action :logged_in_user, only: %i(index)
  skip_before_action :ensure_user_role, only: %i(index)
  before_action :set_course,
                :set_user_course, :set_lessons,
                :set_progress_data, only: %i(show)

  # GET user/courses
  def index
    @pagy, @courses = pagy Course.recent.with_users, limit: Settings.page_6
  end

  # GET user/courses/:id
  def show; end

  # POST user/courses
  def create; end

  private

  def set_course
    @course = Course.find_by(id: params[:id])
    return if @course

    flash[:danger] = t(".error.course_not_found")
    redirect_to root_path
  end

  def set_user_course
    @user_course = current_user.user_courses.find_by(course_id: @course.id)

    return if @user_course.present? && !@user_course.pending?

    flash[:danger] = t(".error.not_enrolled")
    redirect_to root_path
  end

  def set_lessons
    @lessons = @course.lessons.order(:position)
    @total_lessons = @lessons.count
    @learners_count = @course.user_courses.distinct.count(:user_id)
    @duration = @course.duration
  end

  def set_progress_data
    return set_empty_progress unless current_user

    lesson_ids = @lessons.pluck(:id)
    @user_lessons = current_user.user_lessons.where(lesson_id: lesson_ids)
    @completed_count = @user_lessons.where(status: 1).count
    @progress = calculate_progress
  end

  def set_empty_progress
    @user_lessons = %i()
    @completed_count = 0
    @progress = 0
  end

  def calculate_progress
    return 0 if @total_lessons.zero?

    ((@completed_count.to_f / @total_lessons) * 100).round
  end
end
