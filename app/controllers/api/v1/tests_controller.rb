class Api::V1::TestsController < ApplicationController
  # GET /api/v1/tests
  def search
    tests = Test.by_name(params[:query]).limit(10)
    render json: tests.select(:id, :name)
  end
end
