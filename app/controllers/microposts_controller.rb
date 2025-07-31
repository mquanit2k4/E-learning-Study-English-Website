class MicropostsController < ApplicationController
  def index
    @microposts = Micropost.recent
  end
end
