class Api::V1::WordsController < ApplicationController
  # GET /api/v1/words/search
  def search
    words = Word.by_content(params[:query])
    render json: words.select(:id, :content)
  end
end
