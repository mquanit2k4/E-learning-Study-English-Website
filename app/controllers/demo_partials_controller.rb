class DemoPartialsController < ApplicationController
  def new
    @zone = t(".zone_new")
    @date = Time.zone.today
  end

  def edit
    @zone = t(".zone_edit")
    @date = Time.zone.today - 4
  end
end
