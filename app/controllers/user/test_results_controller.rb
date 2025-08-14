class User::TestResultsController < User::ApplicationController
  before_action :set_course_and_lesson, only: %i(show)
  before_action :set_test_result, only: %i(show)
  before_action :check_authorization, only: %i(show)

  # GET /user/courses/:course_id/lessons/:lesson_id/test_results/:test_result_id
  def show
    @test_component = @test_result.component
    @test = @test_component.test
    @questions = @test.questions.includes(:answers).order(:id)
    @total_questions = @questions.count
    @user_answers_data = @test_result.user_answers || {}
  end

  private

  def set_course_and_lesson
    @course = Course.find_by(id: params[:course_id])
    @lesson = @course&.lessons&.find_by(id: params[:lesson_id])
    return if @course && @lesson

    flash[:danger] = t(".error.course_or_lesson_not_found")
    redirect_to root_path
  end

  def set_test_result
    @test_result = TestResult.find_by(id: params[:id])
    return if @test_result

    flash[:danger] = t(".error.test_result_not_found")
    redirect_to user_course_lesson_path(@course, @lesson)
  end

  def check_authorization
    return if @test_result.user == current_user

    flash[:danger] = t(".error.unauthorized_access")
    redirect_to root_path
  end
end
