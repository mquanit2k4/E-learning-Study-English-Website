class User::LessonsController < ApplicationController
  before_action :set_course
  before_action :set_lesson

  # GET user/courses/:course_id/lessons/:id
  def show
    @paragraphs = @lesson.components
                         .paragraph
                         .order(:index_in_lesson)
    @user_lesson = UserLesson.find_by(user: current_user, lesson: @lesson)
    @lesson_test = Component.find_by(lesson: @lesson, component_type: "test")
    @number_of_attempts = TestResult.where(user: current_user,
                                           component: @lesson_test).count
  end

  private

  def set_course
    @course = Course.find_by(id: params[:course_id])
    return if @course

    flash[:danger] = t(".error.course_not_found")
    redirect_to root_path
  end

  def set_lesson
    @lesson = @course.lessons.find_by(id: params[:id])
    return if @lesson

    flash[:danger] = t(".error.lesson_not_found")
    redirect_to user_course_path(@course)
  end
end
