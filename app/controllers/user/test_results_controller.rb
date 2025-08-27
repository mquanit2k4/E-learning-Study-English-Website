class User::TestResultsController < User::ApplicationController
  load_and_authorize_resource :course, class: "Course.name"
  load_and_authorize_resource :lesson, through: :course, shallow: true
  load_and_authorize_resource :test_result, through: :lesson, shallow: true

  # GET /user/courses/:course_id/lessons/:lesson_id/test_results/:id
  def show
    @test_component = @test_result.component
    @test = @test_component.test
    @questions = @test.questions.includes(:answers).order(:id)
    @total_questions = @questions.count
    @user_answers_data = @test_result.user_answers || {}
  end
end
